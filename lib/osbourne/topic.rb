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
      return if Osbourne.test_mode?

      Osbourne.logger.info "[PUB] TOPIC: `#{name}` MESSAGE: `#{message}`"
      sns.publish(topic_arn: arn, message: message.is_a?(String) ? message : message.to_json)
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
  end
end
