# frozen_string_literal: true

module Osbourne
  module Services
    module QueueProvisioner
      def provision_worker_queues
        return if Osbourne.test_mode?

        Osbourne.logger.info "Workers found: #{Osbourne::WorkerBase.descendants.map(&:name).join(', ')}"
        Osbourne.logger.info "Provisioning queues for all workers"

        Osbourne::WorkerBase.descendants.each(&:provision)
      end
    end
  end
end
