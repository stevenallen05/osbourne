# frozen_string_literal: true

require "spec_helper"

RSpec.describe Osbourne::Subscription, type: :model do
  include_context "with mock sns"
  include_context "with mock sqs"

  let(:queue) { Osbourne::Queue.new("queue_name") }
  let(:topics) { [Osbourne::Topic.new("topic_name")] }

  it "subscribes to a topic" do
    expect(mock_sqs_client).to receive(:set_queue_attributes).with(include(attributes: anything,
                                                                           queue_url:  anything)) do |_args|
      OpenStruct.new(attributes: {"QueueArn": "arn:aws:sqs:us-east-2:123456789012:some_queue_arn"}.stringify_keys)
    end
    described_class.new(topics, queue)
  end
end
