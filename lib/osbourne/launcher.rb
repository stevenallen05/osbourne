# frozen_string_literal: true

require "osbourne"

module Osbourne
  class Launcher
    attr_accessor :threads
    def initialize; end

    def start!
      Osbourne.logger.info("Launching Osbourne workers")
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
        Osbourne.logger.debug("Spawning thread for #{worker.name}")
        Thread.new { poll(worker) }
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
      worker.polling_queue.poll(wait_time_seconds:      worker.config[:max_wait_time],
                                max_number_of_messages: worker.config[:max_batch_size],
                                skip_delete:            true) do |messages|
        messages.map do |msg|
          worker.polling_queue.delete_message(msg) if process(worker, Osbourne::Message.new(msg))
        end
        throw :stop_polling if @stop
      end
    end

    private

    def process(worker, message)
      Osbourne.logger.info("[MSG] Worker: #{worker.name} Valid: #{message.valid?} ID: #{message.id}")
      return false unless message.valid? && Osbourne.lock.soft_lock(message.id)

      Osbourne.cache.fetch(message.id, ex: 24.hours) do
        worker.new.process(message).tap {|_| Osbourne.lock.unlock(message.id) }
      end
    rescue Exception => ex # rubocop:disable Lint/RescueException
      Osbourne.logger.error("[MSG ID: #{message.id}] #{ex.message}")
      false
    end
  end
end
