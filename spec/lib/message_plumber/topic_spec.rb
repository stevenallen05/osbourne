# frozen_string_literal: true

require "spec_helper"

RSpec.describe MessagePlumber::Topic, type: :model do
  subject { described_class.new(topic_name) }

  let(:topic_name) { "a_topic" }

  it { byebug }
end
