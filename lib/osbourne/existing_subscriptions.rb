# frozen_string_literal: true

module Osbourne
  module ExistingSubscriptions
    attr_reader :existing_subscriptions
    def existing_subscriptions_for(topic)
      @existing_subscriptions ||= {}
      @existing_subscriptions[topic.name] ||= fetch_existing_subscriptions_for(topic)
    end

    def clear_subscriptions_for(topic)
      @existing_subscriptions[topic.name] = nil
    end

    private

    def fetch_existing_subscriptions_for(topic)
      results = []
      r = nil
      Osbourne.config.hard_lock("osbourne_fetch_sub_lock_#{topic.name}")
      loop do
        params = {topic_arn: topic.arn}
        params[:next_token] = r.next_token if r.try(:next_token)
        r = Osbourne.sns_client.list_subscriptions_by_topic(params)
        results << r.subscriptions.map(&:endpoint)
        break unless r.try(:next_token).presence
      end
      Osbourne.config.unlock("osbourne_fetch_sub_lock_#{topic.name}")
      results.flatten.uniq
    end
  end
end
