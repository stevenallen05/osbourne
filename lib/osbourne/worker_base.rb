# frozen_string_literal: true

module Osbourne
  class WorkerBase
    attr_accessor :topics, :queue, :subscriptions
    def initialize
      register
    end

    @config = {}

    def config
      self.class.config
    end

    def config=(config)
      self.class.config = config
    end

    class << self
      attr_accessor :config

      def descendants
        ObjectSpace.each_object(Class).select {|klass| klass < self }
      end
    end

    def max_recieve_count
      Osbourne.max_recieve_count
    end

    def dead_letter_queue_name
      "#{config[:queue_name]}-dead-letter"
    end

    def dead_letter_queue
      @dead_letter_queue ||= Queue.new(dead_letter_queue_name)
    end

    private

    def redrive_policy
      {maxReceiveCount:     "5",
       deadLetterTargetArn: dead_letter_queue.arn}.to_json
    end

    def register_dead_letter_queue
      return unless Osbourne.config.dead_letter

      queue.redrive(redrive_policy)
    end

    def register
      self.topics = config[:topic_names].map {|tn| Topic.new(tn) }
      self.queue = Queue.new(config[:queue_name])
      self.subscriptions = topics.map {|t| Subscription.new(t, queue) }
      register_dead_letter_queue
    end

    class << self
      def default_queue_name
        "#{name.underscore}_queue"
      end

      def worker_config(topics: [], queue_name: nil)
        self.config = {
          topic_names: Array(topics),
          queue_name:  queue_name.presence || default_queue_name
        }
      end
    end
  end
end
