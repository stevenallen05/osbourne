# frozen_string_literal: true

require "osbourne/test/message"
module Osbourne
  module Test
    class MockPubsub
      class << self
        def mock_publish(topic, message)
          prefixed_topic = Osbourne.prefixer(topic)
          parsed_message = parse(message)
          Osbourne::WorkerBase.descendants.each do |worker|
            msg = Osbourne::Test::Message.new(topic: prefixed_topic, body: parsed_message)
            worker.new.process(msg) if worker.config[:topic_names].include? prefixed_topic
          end
        end

        def parse(message)
          return message if message.is_a?(String)
          return message.to_json if message.respond_to?(:to_json)

          raise ArgumentError, "Message must either be a string or respond to #to_json"
        end
      end
    end
  end
end
