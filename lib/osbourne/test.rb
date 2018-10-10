# frozen_string_literal: true

require "osbourne/test/mock_pubsub"
require "osbourne/test/message"

module Osbourne
  class << self
    def test_mode?
      true
    end

    def publish(topic, message)
      Osbourne::Test::MockPubsub.mock_publish(topic, message)
    end
  end
end
