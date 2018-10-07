# frozen_string_literal: true

require "spec_helper"

lock_class = Class.new do
  include Osbourne::Locks::Base

  def lock(key, ttl); end

  def lock!(key, ttl); end

  def unlock!(key); end
end

incomplete_lock_class = Class.new do
  include Osbourne::Locks::Base
end

RSpec.describe Osbourne::Locks::Base, type: :model do
  subject(:base_lock) { lock_class.new }

  describe "#soft_lock" do
    let(:id) { SecureRandom.hex(100) }

    describe "when the class has defined #lock" do
      it "delegates to the #lock method" do
        expect(base_lock).to receive(:lock).with("osbourne:lock:#{id}", described_class::DEFAULT_SOFT_TTL)
        base_lock.soft_lock(id)
      end

      it "does not raise an error" do
        expect { base_lock.soft_lock(id) }.not_to raise_error
      end
    end

    describe "when the class has not defined #lock" do
      subject(:base_lock) { incomplete_lock_class.new }

      it "raises an error" do
        expect { base_lock.soft_lock(id) }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "#hard_lock" do
    let(:id) { SecureRandom.hex(100) }

    describe "when the class has defined #lock!" do
      it "delegates to the #lock! method" do
        expect(base_lock).to receive(:lock!).with("osbourne:lock:#{id}", described_class::DEFAULT_HARD_TTL)
        base_lock.hard_lock(id)
      end

      it "does not raise an error" do
        expect { base_lock.hard_lock(id) }.not_to raise_error
      end
    end

    describe "when the class has not defined #lock!" do
      subject(:base_lock) { incomplete_lock_class.new }

      it "raises an error" do
        expect { base_lock.hard_lock(id) }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "#unlock" do
    let(:id) { SecureRandom.hex(100) }

    describe "when the class has defined #unlock!" do
      it "delegates to the #unlock method" do
        expect(base_lock).to receive(:unlock!).with("osbourne:lock:#{id}")
        base_lock.unlock(id)
      end

      it "does not raise an error" do
        expect { base_lock.unlock(id) }.not_to raise_error
      end
    end

    describe "when the class has not defined #unlock!" do
      subject(:base_lock) { incomplete_lock_class.new }

      it "raises an error" do
        expect { base_lock.unlock(id) }.to raise_error(NotImplementedError)
      end
    end
  end
end
