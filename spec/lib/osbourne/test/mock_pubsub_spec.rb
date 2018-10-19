# frozen_string_literal: true

require "spec_helper"

class MockPubSubTestWorker < Osbourne::WorkerBase
  class << self
    attr_accessor :processed
  end

  worker_config topics: %w[test_pubsub_topic]

  def process(_message)
    self.class.processed = self.class.processed.to_i + 1
  end
end

class MockJsonable
  def initialize(payload)
    @payload = payload
    undef :to_s
  end

  def to_json
    {payload: @payload}.to_json
  end
end
class MockNonJsonable; end

RSpec.describe Osbourne::Test::MockPubsub do
  subject(:mock_pubsub) { described_class }

  let(:worker) { MockPubSubTestWorker }

  before { Osbourne.test_mode = true }

  after { Osbourne.test_mode = false }

  it { expect { mock_pubsub.mock_publish("test_pubsub_topic", "message") }.to change(worker, :processed) }
  it { expect { mock_pubsub.mock_publish("not_a_real_topic", "message") }.not_to change(worker, :processed) }

  context "when message is a string" do
    it "publishes to SNS" do
      mock_pubsub.mock_publish("test_pubsub_topic", "test")
    end
  end

  context "when message is a MockJsonable object" do
    let(:payload) { MockJsonable.new("thing") }

    it "publishes to SNS" do
      expect { mock_pubsub.mock_publish("test_pubsub_topic", payload) }.not_to raise_error ArgumentError
    end
  end

  context "when message is neither a string nor MockJsonable" do
    it "publishes to SNS" do
      MockNonJsonable.instance_eval { undef :to_json }
      expect { mock_pubsub.mock_publish("test_pubsub_topic", MockNonJsonable) }.to raise_error ArgumentError
    end
  end
end
