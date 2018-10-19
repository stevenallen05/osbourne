# frozen_string_literal: true

module Osbourne
  class Topic
    include Services::SNS
    attr_reader :name
    def initialize(name)
      @name = name
      arn
    end

    def arn
      @arn ||= ensure_topic
    end

    def publish(message)
      parsed_message = parse(message)
      return if Osbourne.test_mode?

      Osbourne.logger.info "[PUB] TOPIC: `#{name}` MESSAGE: `#{parsed_message}`"
      sns.publish(topic_arn: arn, message: parsed_message)
    end

    private

    def ensure_topic
      return if Osbourne.test_mode?

      Osbourne.logger.debug "Ensuring topic `#{name}` exists"
      Osbourne.cache.fetch("osbourne_existing_topic_arn_for_#{name}", ex: 1.minute) do
        sns.create_topic(name: name).topic_arn
      end
    end

    def subscriptions_cache_key
      "existing_sqs_subscriptions_for_#{name}"
    end

    def parse(message)
      return message if message.is_a?(String)
      return message.to_json if message.respond_to?(:to_json)

      raise ArgumentError, "Message must either be a string or respond to #to_json"
    end
  end
end
