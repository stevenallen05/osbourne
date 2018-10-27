# frozen_string_literal: true

require "spec_helper"
class Jsonable
  def initialize(payload)
    @payload = payload
    undef :to_s
  end

  def to_json
    {payload: @payload}.to_json
  end
end
class NonJsonable; end

RSpec.describe Osbourne::Topic, type: :model do
  include_context "with mock sns"
  subject(:topic) { described_class.new("topic_name") }

  it "creates the topic and retrieves the ARN" do
    expect(topic.arn).to be_a(String)
  end

  it { expect(topic.prefixed_name).to start_with Rails.env }

  context "when message is a string" do
    it "publishes to SNS" do
      expect(sns_client).to receive(:publish).with(topic_arn: topic.arn,
                                                   message:   "test")
      Osbourne.publish("topic_name", "test")
    end
  end

  context "when message is a jsonable object" do
    let(:payload) { Jsonable.new("thing") }

    it "publishes to SNS" do
      expect(sns_client).to receive(:publish).with(topic_arn: topic.arn,
                                                   message:   payload.to_json)

      expect { Osbourne.publish("topic_name", payload) }.not_to raise_error ArgumentError
    end
  end

  context "when message is neither a string nor jsonable" do
    it "publishes to SNS" do
      NonJsonable.instance_eval { undef :to_json }
      expect { Osbourne.publish("topic_name", NonJsonable) }.to raise_error ArgumentError
    end
  end
end
