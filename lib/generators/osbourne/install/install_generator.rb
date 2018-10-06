# frozen_string_literal: true

require "rails/generators"

module Osbourne
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def generate_install
      template "osbourne_yaml_template.template", "config/osbourne.yml"
      template "osbourne_initializer_template.template", "config/initializers/osbourne.rb"
    end
  end
end
