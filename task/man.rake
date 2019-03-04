# frozen_string_literal: true

begin
  require "ronn"

  namespace :man do
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
rescue LoadError
  namespace :man do
    task(:require) { abort "Install the ronn gem to be able to release!" }
    task(:build) { warn "Install the ronn gem to build the help pages" }
  end
end
