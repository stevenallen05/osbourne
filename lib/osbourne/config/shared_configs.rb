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

      def max_retry_count
        @max_retry_count ||= (config.max_retry_count.presence || 5).to_s
      end

      def logger
        config.logger ||= Logger.new(STDOUT)
      end

      def lock
        config.lock || Osbourne::Locks::NOOP.new
      end
    end
  end
end
