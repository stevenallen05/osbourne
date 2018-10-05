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

    def subscribe(queue)
      Osbourne.cache.fetch("osbourne_sub_t_#{name}_q_#{queue.name}") do
        sns.subscribe(topic_arn: arn, protocol: "sqs", endpoint: queue.arn)
      end
    end

    private

    def ensure_topic
      Osbourne.cache.fetch("osbourne_existing_topic_arn_for_#{name}") do
        sns.create_topic(name: name).topic_arn
      end
    end

    def subscriptions_cache_key
      "existing_sqs_subscriptions_for_#{name}"
    end
  end
end
