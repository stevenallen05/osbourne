# frozen_string_literal: true

require "message_plumber/railtie"
require "message_plumber/services/sns"
require "message_plumber/topic"

module MessagePlumber
  class << self
    attr_accessor :cache
    attr_writer :sns_client
    def sns_client
      @sns_client ||= Aws::SNS::Client.new(MessagePlumber.sns_config.aws_options)
    end
  end
end
