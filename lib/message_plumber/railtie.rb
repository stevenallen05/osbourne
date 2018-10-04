# frozen_string_literal: true

require "rails"
# require 'message_plumber/config/file_loader'

module MessagePlumber
  class Railtie < Rails::Railtie
    config.message_plumber = ActiveSupport::OrderedOptions.new

    initializer "message_plumber" do
      env = ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"

      %w[config/message_plumber.yml.erb config/message_plumber.yml].find do |filename|
        MessagePlumber::Config::FileLoader.load(filename, env)
      end
    end

    initializer "message_plumber.logger" do
      ActiveSupport.on_load(:message_plumber) { self.logger ||= Rails.logger }
    end

    initializer "message_plumber.cache" do
      ActiveSupport.on_load(:message_plumber) { self.cache ||= Rails.cache }
    end
  end
end
