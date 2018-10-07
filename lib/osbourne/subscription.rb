# frozen_string_literal: true

module Osbourne
  class Subscription
    include Services::SNS
    attr_reader :topic, :queue
    def initialize(topic, queue)
      @topic = topic
      @queue = queue
      arn
    end

    def arn
      @arn ||= subscribe
    end

    private

    def subscribe
      Osbourne.cache.fetch("osbourne_sub_t_#{topic.name}_q_#{queue.name}") do
        sns.subscribe(topic_arn: topic.arn, protocol: "sqs", endpoint: queue.arn).subscription_arn
      end
    end
  end
end
