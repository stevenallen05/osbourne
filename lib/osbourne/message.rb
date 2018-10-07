# frozen_string_literal: true

require "osbourne"

module Osbourne
  class Message
    attr_accessor :message
    def initialize(message)
      @message = message
    end

    def valid?
      message.md5_of_body == Digest::MD5.hexdigest(message.body)
    end

    def id
      message.message_id
    end

    def raw_body
      message.body
    end

    def parsed_body
      @parsed_body ||= JSON.parse(message.body).transform_keys(&:downcase).symbolize_keys
    end

    def body
      parsed_body[:message]
    end

    def delete
      message.delete
      Osbourne.logger.info "[MSG ID: #{id}] Cleared"
    end

    def topic
      parsed_body[:topicarn].split(":").last
    end
  end
end
