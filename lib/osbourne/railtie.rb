# frozen_string_literal: true

require "rails"
require "osbourne/config/file_loader"

module Osbourne
  class Railtie < Rails::Railtie
    config.osbourne = ActiveSupport::OrderedOptions.new

    initializer "osbourne.configure", after: :load_config_initializers do |_app|
      env = ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"

      %w[config/osbourne.yml.erb config/osbourne.yml].find do |filename|
        Osbourne::Config::FileLoader.load(filename, env)
      end
    end
  end
end
