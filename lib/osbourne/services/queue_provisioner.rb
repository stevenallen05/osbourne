# frozen_string_literal: true

module Osbourne
  module Services
    module QueueProvisioner
      def provision_worker_queues
        Dir[File.expand_path("app/workers/**/*.rb")].each {|f| require f }
        return if Osbourne.test_mode?

        Osbourne.logger.info "[Osbourne] Workers found: #{Osbourne::WorkerBase.descendants.map(&:name).join(', ')}"
        Osbourne.logger.info "[Osbourne] Provisioning queues for all workers"
        Osbourne::WorkerBase.descendants.each(&:provision)
      end
    end
  end
end
