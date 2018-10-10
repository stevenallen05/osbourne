# frozen_string_literal: true

require "osbourne/test/message"
module Osbourne
  module Test
    class MockPubsub
      class << self
        def mock_publish(topic, message)
          Osbourne::WorkerBase.descendants.each do |worker|
            msg = Osbourne::Test::Message.new(topic: topic, body: message)
            worker.new.process(msg) if worker.config[:topic_names].include? topic
          end
        end
      end
    end
  end
end
