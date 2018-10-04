# frozen_string_literal: true

module Osbourne
  class Queue
    include Services::SQS
    attr_reader :name
    def initialize(name)
      @name = name
      arn
    end

    def arn
      @arn ||= ensure_queue
    end

    def ensure_queue
      Osbourne.cache.fetch("existing_queue_arn_for_#{name}") do
        sns.create_queue(name: name).queue_arn
      end
    end

    private

    def subscriptions_cache_key
      "existing_sqs_subscriptions_for_#{name}"
    end
  end
end
