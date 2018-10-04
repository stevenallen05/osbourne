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
      Osbourne.cache.fetch("arn_for_#{name}") do
        sqs.create_queue(name: name).queue_arn
      end
    end
  end
end
