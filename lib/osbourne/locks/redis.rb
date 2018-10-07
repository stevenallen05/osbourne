# frozen_string_literal: true

module Osbourne
  module Locks
    class Redis
      include Base

      def initialize(options={})
        super(options)

        self.client = options.fetch(:client) do
          require "redis"
          ::Redis.new(options)
        end
      end

      protected

      def lock(key, ttl)
        with_pool do |client|
          client.set(key, (Time.current + ttl).to_i, ex: ttl, nx: true)
        end
      end

      def lock!(key, ttl)
        with_pool do |client|
          client.set(key, (Time.current + ttl).to_i, ex: ttl)
        end
      end

      def unlock!(key)
        with_pool do |client|
          client.del(key)
        end
      end

      private

      attr_accessor :client

      def with_pool(&block)
        if pool?
          client.with(&block)
        else
          yield client
        end
      end

      def pool?
        defined?(ConnectionPool) && client.is_a?(ConnectionPool)
      end
    end
  end
end
