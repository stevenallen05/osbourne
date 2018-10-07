# frozen_string_literal: true

require "spec_helper"

RSpec.shared_context "subscribed queue", shared_context: :metadata do
  before {
    allow(sns_client).to receive(:list_subscriptions_by_topic).with(topic_arn: be_a(String)) do |_args|
      OpenStruct.new(subscriptions: [subscribed_queue.arn])
    end
  }
end
