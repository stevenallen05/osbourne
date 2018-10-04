# frozen_string_literal: true

require "spec_helper"

RSpec.describe Osbourne::Queue, type: :model do
  subject { described_class.new(queue_name) }

  let(:sqs_client) { instance_double("Aws::SQS::Client") }
  let(:queue_arn) { OpenStruct.new(queue_arn: "arn:aws:sqs:us-east-2:123456789012:queue") }
  let(:queue_name) { "queue_name" }

  before {
    allow(sqs_client).to receive(:create_queue).and_return(queue_arn)
    Osbourne.sqs_client = sqs_client
  }
end
