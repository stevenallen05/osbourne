# frozen_string_literal: true

module Osbourne
  module Util
    def fire_event(event, reverse=false, event_options={})
      Osbourne.logger.debug { "Firing '#{event}' lifecycle event" }
      arr = Shoryuken.options[:lifecycle_events][event]
      arr.reverse! if reverse
      arr.each do |block|
        block.call(event_options)
      rescue StandardError => ex
        Osbourne.logger.warn(event: event)
        Osbourne.logger.warn "#{ex.class.name}: #{ex.message}"
      end
    end
  end
end
