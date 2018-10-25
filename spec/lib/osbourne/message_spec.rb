# frozen_string_literal: true

require "spec_helper"

RSpec.describe Osbourne::Message, type: :model do
  include YamlFixture
  subject(:message) { described_class.new(sqs_message) }

  before {
    allow(sqs_message).to receive(:body).and_return(payload["body"])
    allow(sqs_message).to receive(:md5_of_body).and_return(payload["md5_of_body"])
  }

  let(:sqs_message) { instance_double("Aws::SQS::Message") }

  context "when checksum matches" do
    let(:payload) { load_yaml("valid_message.yml") }

    it { expect(message).to be_valid }
    it { expect(message).to be_json }
    it { expect(message.message_body).to be_a(Hash) }
    it { expect(message.topic).to eq("hello") }
    it { expect(message.sns?).to eq true }
  end

  context "when checksum does not match" do
    let(:payload) { load_yaml("bad_md5_message.yml") }

    it { expect(message).not_to be_valid }
    it { expect(message).not_to be_json }
    it { expect(message.message_body).to be_a(Hash) }
    it { expect(message.sns?).to eq true }
  end

  context "when not a SNS message" do
    let(:payload) { load_yaml("not_fanout_message.yml") }

    it { expect(message).not_to be_json }
    it { expect(message).to be_valid }
    it { expect(message.message_body).to be nil }
    it { expect(message.raw_body).to match "TEST MESSAGE" }
    it { expect(message.sns?).to eq false }
  end

  context "when payload has extra keys" do
    let(:payload) { load_yaml("extra_keys_valid_message.yml") }

    it { expect(message).to be_valid }
    it { expect(message).to be_json }
    it { expect(message.message_body).to be_a(Hash) }
    it { expect(message.sns?).to eq true }
  end
end
