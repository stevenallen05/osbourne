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

      def test_mode?
        false
      end

      def test_mode!
        @test_mode = true
      end

      def test_mode=(test_mode)
        @test_mode = test_mode
      end

      def dead_letter
        config.dead_letter ||= true
      end

      def max_retry_count
        @max_retry_count ||= (config.max_retry_count.presence || 5).to_s
      end

      def logger
        config.logger ||= Logger.new("log/osbourne.log")
      end

      def lock
        config.lock || Osbourne::Locks::NOOP.new
      end

      def sleep_time
        config.sleep_time || 15
      end

      def threads_per_worker
        config.threads_per_worker ||= 5
      end
    end
  end
end
