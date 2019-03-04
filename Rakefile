# frozen_string_literal: true

$:.unshift File.expand_path("../lib", __FILE__)
require "benchmark"

NULL_DEVICE = (Gem.win_platform? ? "NUL" : "/dev/null")
RUBYGEMS_REPO = if `git -C "#{File.expand_path("..")}" remote --verbose 2> #{NULL_DEVICE}` =~ /rubygems/i
  File.expand_path("..")
else
  File.expand_path("tmp/rubygems")
end

# Benchmark task execution
module Rake
  class Task
    alias_method :real_invoke, :invoke

    def invoke(*args)
      time = Benchmark.measure(@name) do
        real_invoke(*args)
      end
      puts "#{@name} ran for #{time}"
    end
  end
end

task :override_version do
  next unless version = ENV["BUNDLER_SPEC_SUB_VERSION"]
  version_file = File.expand_path("../lib/bundler/version.rb", __FILE__)
  contents = File.read(version_file)
  unless contents.sub!(/(^\s+VERSION\s*=\s*)"#{Gem::Version::VERSION_PATTERN}"/, %(\\1"#{version}"))
    abort("Failed to change bundler version")
  end
  File.open(version_file, "w") {|f| f << contents }
end

desc "Update vendored SSL certs to match the certs vendored by RubyGems"
task :update_certs => "spec:rubygems:clone_rubygems_master" do
  require "bundler/ssl_certs/certificate_manager"
  Bundler::SSLCerts::CertificateManager.update_from!(RUBYGEMS_REPO)
end

task :default => :spec

Dir["task/*.rake"].each(&method(:load))

task :generate_files => Rake::Task.tasks.select {|t| t.name.start_with?("lib/bundler/generated") }
