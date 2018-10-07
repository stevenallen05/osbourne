# frozen_string_literal: true

require "spec_helper"

RSpec.describe Osbourne::Subscription, type: :model do
  include_context "with mock sns"
  include_context "with mock sqs"
  subject(:subscription) { described_class.new(topic, queue) }

  let(:queue) { Osbourne::Queue.new("queue_name") }
  let(:topic) { Osbourne::Topic.new("topic_name") }

  it "subscribes to a topic" do
    expect(subscription.arn).to be_a(String)
  end
end
