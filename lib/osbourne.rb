# frozen_string_literal: true

require "osbourne/railtie"
require "osbourne/services/sns"
require "osbourne/services/sqs"
require "osbourne/topic"
require "osbourne/queue"
require "osbourne/subscription"

module Osbourne
  class << self
    attr_accessor :cache
    attr_writer :sns_client, :sqs_client
    def sns_client
      @sns_client ||= Aws::SNS::Client.new(Osbourne.sns_config.aws_options)
    end

    def sqs_client
      @sqs_client ||= Aws::SNS::Client.new(Osbourne.sqs_config.aws_options)
    end
  end
end
