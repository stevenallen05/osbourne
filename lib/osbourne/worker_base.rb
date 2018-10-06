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
    end

    private

    def register
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
