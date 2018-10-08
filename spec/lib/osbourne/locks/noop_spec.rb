# frozen_string_literal: true

require "spec_helper"

RSpec.describe Osbourne::Locks::NOOP, type: :model do
  subject(:noop_lock) { described_class.new }

  let(:id) { SecureRandom.hex(100) }

  describe "#soft_lock" do
    it "returns true" do
      expect(noop_lock.soft_lock(id)).to be true
    end
  end

  describe "#lock!" do
    it "returns nil" do
      expect(noop_lock.hard_lock(id)).to be nil
    end
  end
end
