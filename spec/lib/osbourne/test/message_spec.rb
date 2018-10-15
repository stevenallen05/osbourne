# frozen_string_literal: true

require "spec_helper"

RSpec.describe Osbourne::Test::Message, type: :model do
  subject(:test_message) { described_class.new(topic: "thing", body: {stuff: "what"}.to_json) }

  it { expect(test_message.message_body).to be_a(Hash) }
  it { expect(test_message.raw_body).to be_a(String) }
  it { expect(test_message.topic).to eq "thing" }
  it { expect(test_message).to be_valid }
  it { expect(test_message).to be_sns }
  it { expect(test_message).to be_json }
end
