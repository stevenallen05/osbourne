# frozen_string_literal: true

require "spec_helper"

RSpec.describe Osbourne::Locks::Redis, type: :model do
  subject(:redis_lock) { described_class.new(soft_ttl: soft_ttl, hard_ttl: hard_ttl, client: client) }

  let(:soft_ttl) { 30 }
  let(:hard_ttl) { 60 }
  let(:client) { MockRedis.new }

  before do
    client.respond_to?(:flushdb) ? client.flushdb : client.with(&:flushdb)
  end

  describe "with redis connection" do
    it_behaves_like "a lock"
  end

  describe "with redis connection pool" do
    let(:client) { ConnectionPool.new(size: 1) { MockRedis.new } }

    it_behaves_like "a lock"
  end

  describe ".new" do
    subject(:redis_lock) { described_class }

    describe "when client is provided" do
      let(:options) { {soft_ttl: soft_ttl, hard_ttl: hard_ttl, client: client} }

      it "does not create a new client" do
        expect(Redis).not_to receive(:new)
        redis_lock.new(options)
      end
    end

    describe "when client is not provided" do
      let(:options) { {soft_ttl: soft_ttl, hard_ttl: hard_ttl} }

      it "creates a new client" do
        expect(Redis).to receive(:new).with(options)
        redis_lock.new(options)
      end
    end
  end
end
