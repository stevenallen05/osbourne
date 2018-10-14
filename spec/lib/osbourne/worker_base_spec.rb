# frozen_string_literal: true

require "spec_helper"

class WorkerBaseTestObject < Osbourne::WorkerBase
  worker_config topics: %w[test_topic_1 test_topic_2]
end

RSpec.describe Osbourne::WorkerBase, type: :model do
  include_context "with mock sqs"
  include_context "with mock sns"

  subject(:test_worker) { WorkerBaseTestObject }

  before { Osbourne.provision_worker_queues }

  it { expect(test_worker.subscriptions).to be_a(Osbourne::Subscription) }
  it { expect(Osbourne::WorkerBase.descendants).to include WorkerBaseTestObject }
end
