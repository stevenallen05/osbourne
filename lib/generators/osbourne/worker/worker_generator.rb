# frozen_string_literal: true

require "rails/generators"

module Osbourne
  class WorkerGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)
    argument :topic, type: :array

    def generate_worker
      template "worker_template.template", "app/workers/#{name.underscore}_worker.rb"
    end

    private

    def config_file
      Rails.root.join("config", "queue", "queue_workers.yml")
    end
  end
end
