# frozen_string_literal: true

require "aws-sdk-sns"

module MessagePlumber
  module Services
    module SNS
      def sns
        @sns ||= MessagePlumber.sns_client
      end

      def sns=(client)
        MessagePlumber.sns_client = client
      end
    end
  end
end
