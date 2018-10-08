# frozen_string_literal: true

require "osbourne"

module Osbourne
  class Message
    attr_accessor :message
    def initialize(message)
      @message = message
    end

    def json?
      !JSON.parse(parsed_content["Message"]).nil?
    rescue JSON::ParserError
      false
    end

    def valid?
      message.md5_of_body == Digest::MD5.hexdigest(message.body)
    end

    def id
      message.message_id
    end

    def parsed_body
      JSON.parse(parsed_content["Message"])
    rescue JSON::ParserError
      parsed_content["Message"]
    end

    def delete
      message.delete
      Osbourne.logger.info "[MSG ID: #{id}] Cleared"
    end

    def topic
      parsed_content["TopicArn"].split(":").last
    end

    def raw_body
      message.body
    end

    private

    def parsed_content
      @parsed_content ||= JSON.parse(message.body)
    end

    def body
      parsed_content["Message"]
    end
  end
end
