# frozen_string_literal: true

module Osbourne
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
