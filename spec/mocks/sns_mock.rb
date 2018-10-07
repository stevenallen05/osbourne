# frozen_string_literal: true

require "spec_helper"

RSpec.shared_context "with mock sns" do
  let(:sns_client) { instance_double("Aws::SNS::Client") }

  before {
    allow(sns_client).to receive(:create_topic) do |args|
      OpenStruct.new(topic_arn: "arn:aws:sns:us-east-2:123456789012:#{args[:name]}")
    end

    allow(sns_client).to receive(:subscribe).with(topic_arn: be_a(String),
                                                  protocol:  "sqs",
                                                  endpoint:  be_a(String)) do |args|
      OpenStruct.new(subscription_arn: "arn:aws:sns:us-east-2:123456789012:#{args[:topic_arn]}:#{SecureRandom.uuid}")
    end

    allow(sns_client).to receive(:list_subscriptions_by_topic).with(topic_arn: anything) do |_|
      OpenStruct.new(subscriptions: [], next_token: SecureRandom.uuid)
    end

    allow(sns_client).to receive(:list_subscriptions_by_topic).with(topic_arn: anything, next_token: anything) do |_|
      OpenStruct.new(subscriptions: [], next_token: "")
    end

    Osbourne.sns_client = sns_client
  }

  after { Osbourne.sns_client = nil }
end
