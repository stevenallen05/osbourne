# frozen_string_literal: true

require "osbourne"
require "byebug"

module Osbourne
  class Launcher
    attr_accessor :threads
    def initialize; end

    def start!
      Osbourne.logger.info("Launching Osbourne workers")
      @stop = false
      @threads = poll
    end

    def stop
      @stop = true
    end

    def stop!
      @threads.each {|thr| Thread.kill(thr) }
    end

    private

    def poll
      Osbourne::WorkerBase.descendants.map do |worker|
        Thread.new {
          worker_instance = worker.new
          loop do
            worker.polling_queue.receive_messages(
              wait_time_seconds:      worker.config[:max_wait],
              max_number_of_messages: worker.config[:max_batch_size]
            ).each {|msg| process(worker_instance, Osbourne::Message.new(msg)) }
            sleep(Osbourne.sleep_time)

            break if @stop
          end
        }
      end
    end

    def process(worker, message)
      Osbourne.logger.info("[MSG] Worker: #{worker.class.name} Valid: #{message.valid?} ID: #{message.id} Body: #{message.raw_body}") # rubocop:disable Metrics/LineLength
      return unless message.valid?

      # hard_lock to prevent duplicate processing over the hard_lock lifespan
      Osbourne.lock.try_with_lock(message.id, hard_lock: true) do
        message.delete if worker.process(message)
      end
    rescue Exception => ex # rubocop:disable Lint/RescueException
      Osbourne.logger.error("[MSG ID: #{message.id}] #{ex.message}")
    end
  end
end
