# frozen_string_literal: true

require "yaml"
require "erb"
require "fileutils"

require "awesome_print"

module Osbourne
  module Config
    module FileLoader
      def self.load(cfile, environment="development")
        return nil unless File.exist?(cfile)

        base_opts = YAML.safe_load(ERB.new(IO.read(cfile)).result) || {}
        env_opts = base_opts[environment] || {}

        Osbourne.config.sns_config = env_opts["publisher"].symbolize_keys || {}
        Osbourne.config.sqs_config = env_opts["subscriber"].symbolize_keys || {}
        true
      end
    end
  end
end
