# frozen_string_literal: true

module Osbourne
  module Config
    module SharedConfigs
      attr_writer :sqs_config, :sns_config, :aws_credentials, :config

      def config
        @config ||= ActiveSupport::OrderedOptions.new
      end

      def cache
        config.cache ||= ActiveSupport::Cache::NullStore.new
      end

      def dead_letter
        config.dead_letter ||= true
      end

      def max_recieve_count
        config.max_recieve_count.to_s ||= "5"
      end

      def logger
        config.logger ||= Logger.new(STDOUT)
      end
    end
  end
end
