ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

# PARCHE RUBY 4.0 PARA YAML
require "yaml"
if RUBY_VERSION >= "4.0" && YAML.respond_to?(:unsafe_load)
  module YAML
    class << self
      alias_method :load, :unsafe_load
    end
  end
end
