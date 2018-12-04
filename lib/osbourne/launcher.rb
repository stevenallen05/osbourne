# frozen_string_literal: true

require "osbourne"

module Osbourne
  class Launcher
    attr_accessor :threads
    def initialize; end

    def start!
      Osbourne.logger.info("[Osbourne] Launching Osbourne workers")
      @stop = false
      @threads = global_polling_threads
    end

    def wait!
      threads.map(&:join)
    end

    def stop
      puts "Signal caught. Terminating workers..."
      @stop = true
    end

    def stop!
      puts "Signal caught. Terminating workers..."
      @threads.each {|thr| Thread.kill(thr) }
    end

    def global_polling_threads
      Osbourne::WorkerBase.descendants.map do |worker|
        Osbourne.logger.info("[Osbourne] Spawning thread for #{worker.name}")
        Thread.new do
          loop do
            poll(worker)
            break if @stop
          end
        end
      end
    end

    def worker_polling_threads(worker)
      my_threads = []
      worker.config[:threads].times do
        my_threads << Thread.new { poll(worker) }
      end
      my_threads.each(&:join)
    end

    def poll(worker)
      worker.polling_queue.poll(wait_time_seconds:      worker.config[:max_wait],
                                max_number_of_messages: worker.config[:max_batch_size],
                                idle_timeout:           worker.config[:idle_timeout],
                                skip_delete:            true) do |messages|
        Osbourne.logger.info("[Osbourne] Recieved #{messages.count} on #{worker.name}")
        Array(messages).each {|msg| process(worker, Osbourne::Message.new(msg)) }
        throw :stop_polling if @stop
        Osbourne.logger.info("[Osbourne] Waiting for more messages on #{worker.name} for max of #{worker.config[:max_wait]} seconds")
      end
      Osbourne.logger.info("[Osbourne] Idle timeout on #{worker.name}")
    end

    private

    def process(worker, message) # rubocop:disable Metrics/AbcSize
      Osbourne.logger.info("[Osbourne] [MSG] Worker: #{worker.name} Valid: #{message.valid?} ID: #{message.id}")
      return false unless message.valid? && Osbourne.lock.soft_lock(message.id)

      Osbourne.cache.fetch(message.id, ex: 24.hours) do
        worker.new.process(message).tap {|_| Osbourne.lock.unlock(message.id) }
      end
      worker.polling_queue.delete_message(message.message)
    rescue Exception => ex # rubocop:disable Lint/RescueException
      Osbourne.logger.error("[Osbourne] [MSG ID: #{message.id}] [#{ex.message}]\n #{ex.backtrace_locations.join("\n")}")
    ensure
      return # rubocop:disable Lint/EnsureReturn
    end
  end
end
