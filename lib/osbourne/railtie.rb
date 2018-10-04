# frozen_string_literal: true

require "rails"
# require 'osbourne/config/file_loader'

module Osbourne
  class Railtie < Rails::Railtie
    config.osbourne = ActiveSupport::OrderedOptions.new

    initializer "osbourne" do
      env = ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"

      %w[config/osbourne.yml.erb config/osbourne.yml].find do |filename|
        Osbourne::Config::FileLoader.load(filename, env)
      end
    end

    initializer "osbourne.logger" do
      ActiveSupport.on_load(:osbourne) { self.logger ||= Rails.logger }
    end

    initializer "osbourne.cache" do
      ActiveSupport.on_load(:osbourne) { self.cache ||= Rails.cache }
    end
  end
end
