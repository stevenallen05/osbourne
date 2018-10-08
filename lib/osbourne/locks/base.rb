# frozen_string_literal: true

require "osbourne"

module Osbourne
  module Locks
    module Base
      DEFAULT_SOFT_TTL = (5 * 60).freeze        # 5 minutes
      DEFAULT_HARD_TTL = (24 * 60 * 60).freeze  # 24 hours

      attr_reader :soft_ttl, :hard_ttl

      def initialize(options={})
        self.soft_ttl = options.fetch(:soft_ttl, DEFAULT_SOFT_TTL)
        self.hard_ttl = options.fetch(:hard_ttl, DEFAULT_HARD_TTL)
      end

      def soft_lock(id)
        lock(lock_key(id), soft_ttl)
      end

      def hard_lock(id)
        lock!(lock_key(id), hard_ttl)
      end

      def unlock(id)
        unlock!(lock_key(id))
      end

      def try_with_lock(id, hard_lock: false)
        if soft_lock(id)
          begin
            yield
          rescue => e # rubocop:disable Style/RescueStandardError
            unlock(id)
            raise e
          end

          hard_lock(id) if hard_lock
          true
        else
          false
        end
      end

      protected

      def lock(_key, _ttl)
        raise NotImplementedError
      end

      def lock!(_key, _ttl)
        raise NotImplementedError
      end

      def unlock!(_key)
        raise NotImplementedError
      end

      private

      attr_writer :soft_ttl, :hard_ttl

      def lock_key(id)
        "osbourne:lock:#{id}"
      end
    end
  end
end
