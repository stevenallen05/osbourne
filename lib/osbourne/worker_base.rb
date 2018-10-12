# frozen_string_literal: true

module Osbourne
  class WorkerBase
    @config = {}

    def config
      self.class.config
    end

    def process(_message)
      raise NotImplementedError, "#{self} must implement class method `process`"
    end

    def config=(config)
      self.class.config = config
    end

    def queue
      self.class.queue
    end

    def polling_queue
      self.class.polling_queue
    end

    class << self
      attr_accessor :config, :subscriptions, :topics, :queue

      def descendants
        ObjectSpace.each_object(Class).select {|klass| klass < self }
      end

      def provision
        register
        register_dead_letter_queue
      end

      def max_retry_count
        Osbourne.max_retry_count
      end

      def dead_letter_queue_name
        "#{config[:queue_name]}-dead-letter"
      end

      def dead_letter_queue
        @dead_letter_queue ||= Queue.new(dead_letter_queue_name)
      end

      def queue_name
        default_queue_name
      end

      def polling_queue
        @polling_queue ||= Aws::SQS::QueuePoller.new(queue.url, client: Osbourne.sqs_client)
      end
    end

    class << self
      private

      def register_dead_letter_queue
        return unless Osbourne.dead_letter

        Osbourne.logger.info "#{self.class.name} dead letter queue: arn: [#{dead_letter_queue.arn}], max retries: #{max_retry_count}" # rubocop:disable Metrics/LineLength
        queue.redrive(max_retry_count, dead_letter_queue.arn)
      end

      def register
        Osbourne.logger.info "#{self.class.name} subscriptions: Topics: [#{config[:topic_names].join(', ')}], Queue: [#{config[:queue_name]}]" # rubocop:disable Metrics/LineLength
        self.topics = config[:topic_names].map {|tn| Topic.new(tn) }
        self.queue = Queue.new(config[:queue_name])
        self.subscriptions = topics.map {|t| 
                Osbourne.logger.info "Ensuring subscription for #{t.name} to #{queue.url}" # rubocop:disable Metrics/LineLength
                Subscription.new(t, queue)
          
        }
      end

      def default_queue_name
        "#{name.underscore}_queue"
      end

      def worker_config(topics: [], max_batch_size: 10, max_wait: 10)
        self.config = {
          topic_names:    Array(topics),
          queue_name:     queue_name,
          max_batch_size: max_batch_size,
          max_wait:       max_wait
        }
      end
    end
  end
end
