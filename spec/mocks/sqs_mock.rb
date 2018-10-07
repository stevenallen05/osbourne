# frozen_string_literal: true

require "spec_helper"

RSpec.shared_context "mock sqs", shared_context: :metadata do
  let(:sqs_client) { instance_double("Aws::SQS::Client") }

  before {
    allow(sqs_client).to receive(:create_queue) do |args|
      OpenStruct.new(queue_url: "http://localhost/#{args[:name]}")
    end

    allow(sqs_client).to receive(:get_queue_attributes).with(include(queue_url:       anything,
                                                                     attribute_names: anything)) do |_args|
      OpenStruct.new(attributes: {"QueueArn": "arn:aws:sqs:us-east-2:123456789012:some_queue_arn"}.stringify_keys)
    end

    allow(sqs_client).to receive(:set_queue_attributes).with(include(attributes: anything,
                                                                     queue_url:  anything)) do |_args|
      OpenStruct.new(attributes: {"QueueArn": "arn:aws:sqs:us-east-2:123456789012:some_queue_arn"}.stringify_keys)
    end
    Osbourne.sqs_client = sqs_client
  }

  after { Osbourne.sqs_client = nil }
end
