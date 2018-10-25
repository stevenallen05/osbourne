# frozen_string_literal: true

require "osbourne"

##
# Represents a single message recieved by an Osbourne listener

module Osbourne
  class Message
    attr_reader :message
    def initialize(message)
      @message = message
    end

    ##
    #
    # @return [Boolean] This will be `true` if the SNS message is also JSON
    def json?
      return false unless valid?

      sns_body.is_a?(Hash)
    end

    ##
    # Does the message match the checksum? If not, the message has likely been mangled in transit
    # @return [Boolean]
    def valid?
      @valid ||= message.md5_of_body == Digest::MD5.hexdigest(message.body)
    end

    ##
    # Osbourne has built-in message deduplication, but it's still a good idea to do some verification in a worker
    #
    # @return [String] The UUID of the recieved message
    def id
      message.message_id
    end

    ##
    # If the message was broadcast via SNS, the body will be available here.
    #
    # @return [Hash] If the message was JSON
    # @return [String] If the message was not JSON
    # @return [nil] If the message was not broadcast via SNS.
    # @see #raw_body #raw_body for the raw body string
    def message_body
      sns_body
    end

    ##
    # Deletes the message from SQS to prevent retrying against another worker.
    # Osbourne will automatically delete a message sent to a worker as long as the Osourbne::WorkerBase#process method returns `true`

    def delete
      message.delete
      Osbourne.logger.info "[MSG ID: #{id}] Cleared"
    end

    ##
    # The SNS topic that this message was broadcast to
    # @return [String] if the message was broadcast via SNS, this will be the topic
    # @return [nil] if the message was not broadcast via SNS
    def topic
      return nil unless sns?

      json_body["TopicArn"].split(":").last
    end

    ##
    # @return [String] The raw string representation of the message
    def raw_body
      message.body
    end

    ##
    # Just because a message was recieved via SQS, doesn't mean it was originally broadcast via SNS
    # @return [Boolean] Was the message broadcast via SNS?
    def sns?
      json_body.is_a?(Hash) && (%w[Message Type TopicArn MessageId] - json_body.keys).empty?
    end

    private

    def safe_json(content)
      JSON.parse(content)
    rescue JSON::ParserError
      false
    end

    def sns_body
      return unless sns?

      @sns_body ||= safe_json(json_body["Message"]) || json_body["Message"]
    end

    def json_body
      @json_body || safe_json(message.body)
    end
  end
end
