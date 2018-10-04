# frozen_string_literal: true

module MessagePlumber
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

    def ensure_topic
      MessagePlumber.cache.fetch("existing_topic_arn_for_#{name}") do
        sns.create_topic(name: name).topic_arn
      end
    end

    def subscriptions(force: false)
      MessagePlumber.cache.fetch(existing_subscriptions_cache_key(name), force: force) do
        results = []
        next_token = nil
        loop do
          params = {topic_arn: arn, next_token: next_token}
          r = sns.list_subscriptions_by_topic(params)
          results.push(*r.subscriptions.map(&:endpoint))
          next_token = r.next_token
          break if next_token.blank?
        end
        results
      end
    end

    private

    def subscriptions_cache_key
      "existing_sqs_subscriptions_for_#{name}"
    end
  end
end
