# frozen_string_literal: true

require "spec_helper"

class TestWorker < Osbourne::WorkerBase
  worker_config topics: %w[test_topic_1 test_topic_2], max_wait: 10, max_batch_size: 1

  def process(_message)
    self.class.processed ||= 0
    self.class.processed += 1
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

  before { Osbourne.provision_worker_queues }

  context "with a valid payload" do
    let(:payload) { load_yaml("valid_message.yml") }

    it "polls the SQS queue with the expected parameters" do
      expect(mock_sqs_client).to receive(:receive_message).with(include(max_number_of_messages: anything,
                                                                        wait_time_seconds:      anything,
                                                                        queue_url:              anything)) do |_args|
        message_payload
      end
      expect(mock_sqs_client).to receive(:delete_message).with(include(queue_url:      "http://localhost/",
                                                                       receipt_handle: "junk"))
      launcher.stop
      expect { launcher.poll(test_worker) }.to change(test_worker, :processed)
    end
  end

  context "with an invalid payload" do
    let(:payload) { load_yaml("bad_md5_message.yml") }

    it "polls the SQS queue with the expected parameters" do
      expect(mock_sqs_client).to receive(:receive_message).with(include(max_number_of_messages: anything,
                                                                        wait_time_seconds:      anything,
                                                                        queue_url:              anything)) do |_args|
        message_payload
      end
      expect(mock_sqs_client).not_to receive(:delete_message)
      launcher.stop
      expect { launcher.poll(test_worker) }.not_to raise_error
    end
  end

  context "with a non-SNS payload" do
    let(:payload) { load_yaml("not_fanout_message.yml") }

    it "polls the SQS queue with the expected parameters" do
      expect(mock_sqs_client).to receive(:receive_message).with(include(max_number_of_messages: anything,
                                                                        wait_time_seconds:      anything,
                                                                        queue_url:              anything)) do |_args|
        message_payload
      end
      expect(mock_sqs_client).to receive(:delete_message)
      launcher.stop
      expect { launcher.poll(test_worker) }.not_to raise_error
    end
  end
end
