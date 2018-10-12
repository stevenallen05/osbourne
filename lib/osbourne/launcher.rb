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
      @threads = polling_threads
      # @threads.each(&:run)
    end

    def stop
      puts "Signal caught. Terminating workers..."
      @stop = true
    end

    def stop!
      puts "Signal caught. Terminating workers..."
      @threads.each {|thr| Thread.kill(thr) }
    end

    def polling_threads
      Osbourne::WorkerBase.descendants.map do |worker|
        Osbourne.logger.debug("Spawning thread for #{worker.name}")
        Thread.new do
        #   puts ("Polling #{worker.name}: #{worker.queue.url}")
        # Kernel.fork do
          # loop do
            poll(worker)
            # sleep(Osbourne.sleep_time)
            # break if @stop
          # end
        end
        #   puts ("Polling block starting for #{worker.name}: #{worker.queue.url}")
        # }
      end
    end

    def poll(worker)
      my_threads = []
      5.times do
        # my_threads << Thread.new do
        fork do
          worker.polling_queue.poll(wait_time_seconds: worker.config[:max_wait_time], 
                                    max_number_of_messages: worker.config[:max_batch_size],
                                    skip_delete: true) do |messages|
              throw :stop_polling if @stop
              messages.map do |msg|
                 worker.polling_queue.delete_message(msg) if process(worker, Osbourne::Message.new(msg))
              end
          end
        end
      end
      Process.wait
      # my_threads.each(&:join)
    end

    private

    def process(worker, message)
      Osbourne.logger.info("[MSG] Worker: #{worker.class.name} Valid: #{message.valid?} ID: #{message.id}") # rubocop:disable Metrics/LineLength
      return unless message.valid?

      # hard_lock to prevent duplicate processing over the hard_lock lifespan
      Osbourne.cache.fetch(message.id, ex: 24.hours) do
        worker.new.process(message)
      end
    rescue Exception => ex # rubocop:disable Lint/RescueException
      byebug
      Osbourne.logger.error("[MSG ID: #{message.id}] #{ex.message}")
    end
  end
end
