# frozen_string_literal: true

namespace :man do
  begin
    bundler_spec = Gem::Specification.load(File.expand_path("../../bundler.gemspec", __FILE__))
    ronn_dep = bundler_spec.dependencies.find do |dep|
      dep.name == "ronn"
    end

    ronn_requirement = ronn_dep.requirement.to_s

    gem "ronn", ronn_requirement

    require "ronn"
  rescue LoadError
    task(:require) { abort "We couln't activate ronn (#{ronn_requirement}). Try `gem install ronn:'#{ronn_requirement}'` to be able to release!" }
    task(:build) { warn "We couln't activate ronn (#{ronn_requirement}). Try `gem install ronn:'#{ronn_requirement}'` to be able to build the help pages" }
  else
    directory "man"

    index = []
    sources = Dir["man/*.ronn"].map {|f| File.basename(f, ".ronn") }
    sources.map do |basename|
      ronn = "man/#{basename}.ronn"
      manual_section = ".1" unless basename =~ /\.(\d+)\Z/
      roff = "man/#{basename}#{manual_section}"

      index << [ronn, File.basename(roff)]

      file roff => ["man", ronn] do
        sh "#{Gem.ruby} -S ronn --roff --pipe #{ronn} > #{roff}"
      end

      file "#{roff}.txt" => roff do
        sh "groff -Wall -mtty-char -mandoc -Tascii #{roff} | col -b > #{roff}.txt"
      end

      task :build_all_pages => "#{roff}.txt"
    end

    file "index.txt" do
      index.map! do |(ronn, roff)|
        [File.read(ronn).split(" ").first, roff]
      end
      index = index.sort_by(&:first)
      justification = index.map {|(n, _f)| n.length }.max + 4
      File.open("man/index.txt", "w") do |f|
        index.each do |name, filename|
          f << name.ljust(justification) << filename << "\n"
        end
      end
    end
    task :build_all_pages => "index.txt"

    task :clean do
      leftovers = Dir["man/*"].reject do |f|
        File.extname(f) == ".ronn"
      end
      rm leftovers if leftovers.any?
    end

    desc "Build the man pages"
    task :build => ["man:clean", "man:build_all_pages"]

    desc "Remove all built man pages"
    task :clobber do
      rm_rf "lib/bundler/man"
    end

    task(:require) {}
  end
end
