# frozen_string_literal: true

require "aws-sdk-sqs"

module Osbourne
  module Services
    module SQS
      def sqs
        @sqs ||= Osbourne.sqs_client
      end

      def sqs=(client)
        Osbourne.sqs_client = client
      end
    end
  end
end
