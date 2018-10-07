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

    def subscribe # rubocop:disable Metrics/AbcSize
      Osbourne.logger.info("Checking subscription for #{queue.name} to #{topic.name}")
      return if Osbourne.existing_subscriptions_for(topic).include? queue.arn

      Osbourne.config.hard_lock("osbourne_sub_lock_#{topic.name}")
      Osbourne.logger.info("Subscribing #{queue.name} to #{topic.name}")
      @arn = sns.subscribe(topic_arn: topic.arn, protocol: "sqs", endpoint: queue.arn).subscription_arn
      Osbourne.clear_subscriptions_for(topic)
      Osbourne.config.unlock("osbourne_sub_lock_#{topic.name}")
      @arn
    end
  end
end
