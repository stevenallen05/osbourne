# frozen_string_literal: true

require "spec_helper"

class TestWorker < Osbourne::WorkerBase
  worker_config topics: %w[test_topic_1 test_topic_2]

  def process(_message)
    self.class.processed = true
  end

  class << self
    attr_accessor :processed
  end
end

RSpec.describe Osbourne::Launcher, type: :model do
  include YamlFixture
  include_context "with mock sqs"
  include_context "with mock sns"

  subject(:launcher) {  described_class.new }

  let(:test_worker) { TestWorker }
  let(:message_payload) {
    OpenStruct.new(
      messages: [OpenStruct.new(payload.merge(message_id: SecureRandom.uuid, receipt_handle: "junk"))]
    )
  }

  before {
    # Osbourne.config.sleep_time = 0
    Osbourne.provision_worker_queues
  }

  context "with a valid payload" do
    let(:payload) { load_yaml("valid_message.yml") }

    it "polls the SQS queue with the expected parameters" do
      expect(sqs_client).to receive(:receive_message).with(include(max_number_of_messages: anything,
                                                                   wait_time_seconds:      anything,
                                                                   queue_url:              anything)) do |_args|
        message_payload
      end
      expect(sqs_client).to receive(:delete_message).with(include(queue_url:      "http://localhost/",
                                                                  receipt_handle: "junk"))
      launcher.stop
      expect { launcher.poll(test_worker) }.to change(test_worker, :processed)
    end
  end
end
