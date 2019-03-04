# frozen_string_literal: true

begin
  require "automatiek"

  Automatiek::RakeTask.new("molinillo") do |lib|
    lib.download = { :github => "https://github.com/CocoaPods/Molinillo" }
    lib.namespace = "Molinillo"
    lib.prefix = "Bundler"
    lib.vendor_lib = "lib/bundler/vendor/molinillo"
  end

  Automatiek::RakeTask.new("thor") do |lib|
    lib.download = { :github => "https://github.com/erikhuda/thor" }
    lib.namespace = "Thor"
    lib.prefix = "Bundler"
    lib.vendor_lib = "lib/bundler/vendor/thor"
  end

  Automatiek::RakeTask.new("fileutils") do |lib|
    lib.download = { :github => "https://github.com/ruby/fileutils" }
    lib.namespace = "FileUtils"
    lib.prefix = "Bundler"
    lib.vendor_lib = "lib/bundler/vendor/fileutils"
  end

  Automatiek::RakeTask.new("net-http-persistent") do |lib|
    lib.download = { :github => "https://github.com/drbrain/net-http-persistent" }
    lib.namespace = "Net::HTTP::Persistent"
    lib.prefix = "Bundler::Persistent"
    lib.vendor_lib = "lib/bundler/vendor/net-http-persistent"

    mixin = Module.new do
      def namespace_files
        super
        require_target = vendor_lib.sub(%r{^(.+?/)?lib/}, "") << "/lib"
        relative_files = files.map {|f| Pathname.new(f).relative_path_from(Pathname.new(vendor_lib) / "lib").sub_ext("").to_s }
        process_files(/require (['"])(#{Regexp.union(relative_files)})/, "require \\1#{require_target}/\\2")
      end
    end
    lib.send(:extend, mixin)
  end
rescue LoadError
  namespace :vendor do
    task(:fileutils) { abort "Install the automatiek gem to be able to vendor gems." }
    task(:molinillo) { abort "Install the automatiek gem to be able to vendor gems." }
    task(:thor) { abort "Install the automatiek gem to be able to vendor gems." }
    task("net-http-persistent") { abort "Install the automatiek gem to be able to vendor gems." }
  end
end
