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

module Osbourne
  class << self
    include Osbourne::Config::SharedConfigs
    include Osbourne::Services::QueueProvisioner
    attr_writer :sns_client, :sqs_client

    def sns_client
      @sns_client ||= Aws::SNS::Client.new(Osbourne.config.sns_config)
    end

    def sqs_client
      @sqs_client ||= Aws::SQS::Client.new(Osbourne.config.sqs_config)
    end

    def publish(topic, message)
      Topic.new(topic).publish(message)
    end

    def configure
      yield config
    end
  end
end
