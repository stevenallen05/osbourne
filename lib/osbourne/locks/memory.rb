# frozen_string_literal: true

module Osbourne
  module Locks
    class Memory
      include Base

      class << self
        def store
          @store ||= {}
        end

        def semaphore
          @semaphore ||= Mutex.new
        end
      end

      protected

      def lock(key, ttl)
        reap

        store do |store|
          if store.key?(key)
            false
          else
            store[key] = Time.current + ttl
            true
          end
        end
      end

      def lock!(key, ttl)
        reap

        store do |store|
          store[key] = Time.current + ttl
        end
      end

      def unlock!(key)
        store do |store|
          store.delete(key)
        end
      end

      private

      def store
        semaphore.synchronize do
          yield self.class.store
        end
      end

      def reap
        store do |store|
          now = Time.current
          store.delete_if {|_, expires_at| expires_at <= now }
        end
      end

      def semaphore
        self.class.semaphore
      end
    end
  end
end
