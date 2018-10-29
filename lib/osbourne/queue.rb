# frozen_string_literal: true

module Osbourne
  class Queue
    include Services::SQS
    attr_reader :name, :prefixed_name
    def initialize(name)
      @name = name
      @prefixed_name = Osbourne.prefixer(@name)
      arn
    end

    def url
      @url ||= ensure_queue
    end

    def arn
      @arn ||= get_attributes["QueueArn"]
    end

    def redrive(retries, dead_letter_arn)
      sqs.set_queue_attributes(queue_url:  url,
                               attributes: {
                                 'RedrivePolicy': {
                                   'deadLetterTargetArn': dead_letter_arn,
                                   'maxReceiveCount':     retries
                                 }.to_json
                               })
    end

    private

    def ensure_queue
      Osbourne.logger.debug "[Osbourne] Ensuring queue `#{@prefixed_name}` exists"
      Osbourne.cache.fetch("osbourne_url_for_#{@prefixed_name}") do
        sqs.create_queue(queue_name: @prefixed_name).queue_url
      end
    end

    def get_attributes(attrs: %w[QueueArn])
      sqs.get_queue_attributes(queue_url: url, attribute_names: attrs).attributes
    end
  end
end
