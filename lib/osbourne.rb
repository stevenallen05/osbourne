# frozen_string_literal: true

require "osbourne/railtie"
require "osbourne/services/sns"
require "osbourne/services/sqs"
require "osbourne/topic"
require "osbourne/queue"

module Osbourne
  class << self
    attr_accessor :cache
    attr_writer :sns_client
    def sns_client
      @sns_client ||= Aws::SNS::Client.new(Osbourne.sns_config.aws_options)
    end
  end
end
