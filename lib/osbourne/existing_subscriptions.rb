# frozen_string_literal: true

module Osbourne
  module ExistingSubscriptions
    attr_reader :existing_subscriptions
    def existing_subscriptions_for(topic)
      Osbourne.cache.fetch("osbourne_existng_subs_for_#{topic.name}") do
        results = []
        handled = Osbourne.lock.try_with_lock("osbourne_lock_subs_for_#{topic.name}") do
          results = fetch_existing_subscriptions_for(topic)
        end
        return results if handled

        sleep(0.5)
        existing_subscriptions_for(topic)
      end
      # @existing_subscriptions ||= {}
      # @existing_subscriptions[topic.name] ||=
    end

    def clear_subscriptions_for(topic)
      Osbourne.cache.delete("osbourne_existng_subs_for_#{topic.name}")
    end

    private

    def fetch_existing_subscriptions_for(topic)
      results = []
      r = nil
      loop do
        params = {topic_arn: topic.arn}
        params[:next_token] = r.next_token if r.try(:next_token)
        r = Osbourne.sns_client.list_subscriptions_by_topic(params)
        results << r.subscriptions.map(&:endpoint)
        break unless r.try(:next_token).presence
      end
      results.flatten.uniq
    end
  end
end
