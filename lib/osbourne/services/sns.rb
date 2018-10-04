# frozen_string_literal: true

require "aws-sdk-sns"

module Osbourne
  module Services
    module SNS
      def sns
        @sns ||= Osbourne.sns_client
      end

      def sns=(client)
        Osbourne.sns_client = client
      end
    end
  end
end
