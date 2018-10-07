# frozen_string_literal: true

require "spec_helper"

RSpec.describe Osbourne::Queue, type: :model do
  include_context "with mock sqs"
  subject(:queue) { described_class.new(queue_name) }

  let(:queue_name) { "a_queue" }

  it "creates the queue and retrieves the ARN" do
    expect(queue.arn).to be_a(String)
  end
end
