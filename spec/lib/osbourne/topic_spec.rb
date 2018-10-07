# frozen_string_literal: true

require "spec_helper"

RSpec.describe Osbourne::Topic, type: :model do
  include_context "with mock sns"
  subject(:topic) { described_class.new("topic_name") }

  it "creates the topic and retrieves the ARN" do
    expect(topic.arn).to be_a(String)
  end

  it "publishes to SNS" do
    expect(sns_client).to receive(:publish).with(topic_arn: topic.arn,
                                                 message:   "test")
    topic.publish("test")
  end
end
