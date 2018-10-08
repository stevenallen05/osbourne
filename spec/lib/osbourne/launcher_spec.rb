# frozen_string_literal: true

require "spec_helper"

class TestWorker < Osbourne::WorkerBase
  attr_reader :processed
  worker_config topics: %w[test_topic_1 test_topic_2]

  def process(_message)
    @processed = true
  end
end

RSpec.describe Osbourne::Launcher, type: :model do
  include YamlFixture
  include_context "with mock sqs"
  include_context "with mock sns"

  subject(:launcher) {  described_class.new }

  let(:payload) { load_yaml("valid_message.yml") }
  let(:test_worker) { TestWorker.new }

  before {
    allow(sqs_client).to receive(:receive_message).with(include(max_number_of_messages: anything,
                                                                wait_time_seconds:      anything,
                                                                queue_url:              anything)) do |_args|
      OpenStruct.new(
        data: OpenStruct.new(
          messages: [
            OpenStruct.new(payload.merge(message_id: SecureRandom.uuid, receipt_handle: "junk"))
          ]
        )
      )
    end
    Osbourne.config.sleep_time = 0
    Osbourne.provision_worker_queues
    launcher.stop
  }

  it { expect { launcher.poll(test_worker) }.to change(test_worker, :processed) }
end
