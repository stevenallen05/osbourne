# frozen_string_literal: true

module Osbourne
  class << self
    def test_mode?
      true
    end
  end

  class WorkerBase
    @config = {}

    def process(_message)
      raise NotImplementedError, "Sorry, the test stub doesn't do this for you, either"
    end

    def config
      self.class.config
    end

    def config=(config)
      self.class.config = config
    end

    class << self
      attr_accessor :config, :topics

      def descendants; end

      def polling_queue; end

      private

      def worker_config(topics: [], max_batch_size: 10, max_wait: 10)
        self.config = {
          topic_names:    Array(topics),
          max_batch_size: max_batch_size,
          max_wait:       max_wait
        }
      end
    end
  end

  module Test
    class Message
      attr_reader :topic, :parsed_body
      def initialize(topic:, body:)
        @topic = topic
        @parsed_body = body
      end

      def id
        @id ||= SecureRandom.uuid
      end

      def valid?
        true
      end
    end
  end
end
