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

    def redrive(redrive_policy)
      sqs.set_queue_attributes(queue_url: url, attributes: redrive_policy)
    end

    private

    def ensure_queue
      Osbourne.logger.debug "Ensuring queue `#{name}` exists"
      Osbourne.cache.fetch("osbourne_url_for_#{name}") do
        sqs.create_queue(queue_name: name).queue_url
      end
    end

    def get_attributes(attrs: %w[QueueArn])
      sqs.get_queue_attributes(queue_url: url, attribute_names: attrs).attributes
    end
  end
end
