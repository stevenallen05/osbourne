# frozen_string_literal: true

require "osbourne/railtie"
require "osbourne/services/sns"
require "osbourne/services/sqs"
require "osbourne/topic"
require "osbourne/queue"
require "osbourne/subscription"
require "osbourne/config/shared_configs"
require "osbourne/worker_base"
require "osbourne/services/queue_provisioner"
require "osbourne/launcher"
require "osbourne/message"
require "osbourne/existing_subscriptions"
require "osbourne/locks/base"
require "osbourne/locks/noop"
require "osbourne/locks/memory"
require "osbourne/locks/redis"

module Osbourne
  class << self
    include Osbourne::Config::SharedConfigs
    include Osbourne::Services::QueueProvisioner
    include Osbourne::ExistingSubscriptions
    # attr_writer :sns_client, :sqs_client

    def sns_client
      return if Osbourne.test_mode?

      @sns_client ||= Aws::SNS::Client.new(Osbourne.config.sns_config)
    end

    def sqs_client
      return if Osbourne.test_mode?

      @sqs_client ||= Aws::SQS::Client.new(Osbourne.config.sqs_config)
    end

    attr_writer :sns_client

    attr_writer :sqs_client

    def publish(topic, message)
      Topic.new(topic).publish(message)
    end

    def configure
      yield config
    end

    def prefixer(str)
      [Osbourne.prefix, str].reject(&:blank?).reject(&:nil?).join("_")
    end
  end
end
