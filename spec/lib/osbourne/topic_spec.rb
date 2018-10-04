# frozen_string_literal: true

require "spec_helper"

RSpec.describe Osbourne::Topic, type: :model do
  subject { described_class.new(topic_name) }

  let(:sns_client) { instance_double("Aws::SNS::Client") }
  let(:topic_arn) { OpenStruct.new(topic_arn: "arn:aws:sns:us-east-2:123456789012:topic") }
  let(:topic_name) { "topic_name" }

  before {
    allow(sns_client).to receive(:create_topic).and_return(topic_arn)
    Osbourne.sns_client = sns_client
  }
end
