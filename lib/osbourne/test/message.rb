# frozen_string_literal: true

module Osbourne
  module Test
    class Message < Osbourne::Message
      attr_reader :topic, :raw_body
      def initialize(topic:, body:)
        @topic = topic
        @raw_body = body
      end

      def id
        @id ||= SecureRandom.uuid
      end

      def valid?
        true
      end

      def delete; end

      def sns?
        true
      end

      private

      def sns_body
        @sns_body ||= safe_json(raw_body) || raw_body
      end
    end
  end
end
