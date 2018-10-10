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

RSpec.describe Osbourne::Test::MockPubsub do
  subject(:mock_pubsub) { described_class }

  let(:worker) { MockPubSubTestWorker }

  before { Osbourne.test_mode = true }

  after { Osbourne.test_mode = false }

  it { expect { mock_pubsub.mock_publish("test_pubsub_topic", "message") }.to change(worker, :processed) }
  it { expect { mock_pubsub.mock_publish("not_a_real_topic", "message") }.not_to change(worker, :processed) }
end
