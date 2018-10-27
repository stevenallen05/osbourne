# frozen_string_literal: true

module Osbourne
  class Topic
    include Services::SNS
    attr_reader :name
    attr_reader :prefixed_name
    def initialize(name)
      @name = name
      @prefixed_name = Osbourne.prefixer(name)
      arn
    end

    def arn
      @arn ||= ensure_topic
    end

    def publish(message)
      parsed_message = parse(message)
      return if Osbourne.test_mode?

      Osbourne.logger.info "[PUB] TOPIC: `#{prefixed_name}` MESSAGE: `#{parsed_message}`"
      sns.publish(topic_arn: arn, message: parsed_message)
    end

    private

    def ensure_topic
      return if Osbourne.test_mode?

      Osbourne.logger.debug "Ensuring topic `#{prefixed_name}` exists"
      Osbourne.cache.fetch("osbourne_existing_topic_arn_for_#{prefixed_name}", ex: 1.minute) do
        sns.create_topic(name: prefixed_name).topic_arn
      end
    end

    def subscriptions_cache_key
      "existing_sqs_subscriptions_for_#{prefixed_name}"
    end

    def parse(message)
      return message if message.is_a?(String)
      return message.to_json if message.respond_to?(:to_json)

      raise ArgumentError, "Message must either be a string or respond to #to_json"
    end
  end
end
