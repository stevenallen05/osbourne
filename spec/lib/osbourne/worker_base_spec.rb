# frozen_string_literal: true

require "spec_helper"

class TestWorker < Osbourne::WorkerBase
  worker_config topics: %w[test_topic_1 test_topic_2]
end

RSpec.describe Osbourne::WorkerBase, type: :model do
  include_context "mock sqs"
  include_context "mock sns"

  subject(:test_worker) { TestWorker }

  before { Osbourne.provision_worker_queues }

  it { expect(test_worker.subscriptions.count).to eq 2 }
  it { expect(Osbourne::WorkerBase.descendants).to contain_exactly TestWorker }
end
