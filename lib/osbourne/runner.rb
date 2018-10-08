# frozen_string_literal: true

$stdout.sync = true

require "singleton"

require "osbourne"

module Osbourne
  class Shutdown < Interrupt; end # rubocop:disable Lint/InheritException

  class Runner
    include Singleton

    # rubocop:disable Metrics/MethodLength
    def run
      self_read, self_write = IO.pipe

      %w[INT TERM USR1 TSTP TTIN].each do |sig|
        begin
          trap sig do
            self_write.puts(sig)
          end
        rescue ArgumentError
          puts "Signal #{sig} not supported"
        end
      end

      @launcher = Osbourne::Launcher.new

      begin
        @launcher.start!

        while readable_io = IO.select([self_read]) # rubocop:disable Lint/AssignmentInCondition
          signal = readable_io.first[0].gets.strip
          handle_signal(signal)
        end
        @launcher.threads.map(&:join)
      rescue Interrupt
        @launcher.stop!
        exit 0
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def execute_soft_shutdown
      Osbourne.logger.info { "Received USR1, will soft shutdown down" }

      @launcher.stop
      exit 0
    end

    def execute_terminal_stop
      Osbourne.logger.info { "Received TSTP, will stop accepting new work" }

      @launcher.stop!
    end

    def print_threads_backtrace
      Thread.list.each do |thread|
        Osbourne.logger.info { "Thread TID-#{thread.object_id.to_s(36)} #{thread['label']}" }
        if thread.backtrace
          Osbourne.logger.info { thread.backtrace.join("\n") }
        else
          Osbourne.logger.info { "<no backtrace available>" }
        end
      end
    end

    def handle_signal(sig)
      Osbourne.logger.debug "Got #{sig} signal"

      case sig
      when "USR1" then execute_soft_shutdown
      when "TTIN" then print_threads_backtrace
      when "TSTP" then execute_terminal_stop
      when "TERM", "INT"
        Osbourne.logger.info { "Received #{sig}, will shutdown" }

        raise Interrupt
      end
    end
  end
end
