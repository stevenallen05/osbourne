# frozen_string_literal: true

require "yaml"
require "erb"
require "fileutils"

module Osbourne
  module Config
    module FileLoader
      def self.load(cfile, environment="development")
        return false unless should_run?(cfile)

        base_opts = YAML.safe_load(ERB.new(IO.read(cfile)).result) || {}
        env_opts = base_opts[environment] || {}

        Osbourne.config.sns_config = env_opts["publisher"]&.symbolize_keys || {}
        Osbourne.config.sqs_config = env_opts["subscriber"]&.symbolize_keys || {}
        true
      end

      def self.should_run?(cfile)
        File.exist?(cfile) && !Osbourne.test_mode?
      end
    end
  end
end
