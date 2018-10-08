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
    it { expect(message.parsed_body).to be_a(Hash) }
    it { expect(message.topic).to eq("hello") }
  end

  context "when checksum does not match" do
    let(:payload) { load_yaml("bad_md5_message.yml") }

    it { expect(message).not_to be_valid }
    it { expect(message).to be_json }
    it { expect(message.parsed_body).to be_a(Hash) }
  end

  context "when not valid json" do
    let(:payload) { load_yaml("not_fanout_message.yml") }

    it { expect(message).not_to be_json }
    it { expect(message).to be_valid }
    it { expect(message.parsed_body).to be_a(String) }
  end
end
