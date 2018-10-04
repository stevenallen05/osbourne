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

    def ensure_topic
      Osbourne.cache.fetch("existing_topic_arn_for_#{name}") do
        sns.create_topic(name: name).topic_arn
      end
    end

    private

    def subscriptions_cache_key
      "existing_sqs_subscriptions_for_#{name}"
    end
  end
end
