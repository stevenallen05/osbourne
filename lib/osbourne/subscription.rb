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
      Osbourne.logger.info("Checking subscription for #{queue.name} to #{topic.name}")

      return if Osbourne.existing_subscriptions_for(topic).include? queue.arn

      Osbourne.logger.info("Subscribing #{queue.name} to #{topic.name}")
      sns.subscribe(topic_arn: topic.arn, protocol: "sqs", endpoint: queue.arn).subscription_arn
      Osbourne.clear_subscriptions_for(topic)
    end
  end
end
