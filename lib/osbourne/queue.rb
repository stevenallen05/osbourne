# frozen_string_literal: true

module Osbourne
  class Queue
    include Services::SQS
    attr_reader :name
    def initialize(name)
      @name = name
      arn
    end

    def url
      @url ||= ensure_queue
    end

    def arn
      @arn ||= get_attributes["QueueArn"]
    end

    private

    def ensure_queue
      Osbourne.cache.fetch("osbourne_url_for_#{name}") do
        sqs.create_queue(name: name).queue_url
      end
    end

    def get_attributes(attrs: %w[QueueArn])
      sqs.get_queue_attributes(queue_url: url, attribute_names: attrs).attributes
    end
  end
end
