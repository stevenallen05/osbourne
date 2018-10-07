# frozen_string_literal: true

module Osbourne
  class WorkerBase
    attr_accessor :topics, :queue, :subscriptions
    def initialize
      register
    end

    def provision
      register
      register_dead_letter_queue
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

    def max_retry_count
      Osbourne.max_retry_count
    end

    def dead_letter_queue_name
      "#{config[:queue_name]}-dead-letter"
    end

    def dead_letter_queue
      @dead_letter_queue ||= Queue.new(dead_letter_queue_name)
    end

    private

    def register_dead_letter_queue
      return unless Osbourne.dead_letter

      Osbourne.logger.info "#{self.class.name} dead letter queue: arn: [#{dead_letter_queue.arn}], max retries: #{max_retry_count}" # rubocop:disable Metrics/LineLength
      queue.redrive(max_retry_count, dead_letter_queue.arn)
    end

    def register # rubocop:disable Metrics/AbcSize
      Osbourne.logger.info "#{self.class.name} subscriptions: Topics: [#{config[:topic_names].join(', ')}], Queue: [#{config[:queue_name]}]" # rubocop:disable Metrics/LineLength
      self.topics = config[:topic_names].map {|tn| Topic.new(tn) }
      self.queue = Queue.new(config[:queue_name])
      self.subscriptions = topics.map {|t| Subscription.new(t, queue) }
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
