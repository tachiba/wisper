# Logger for broadcast event. This unlikely to be threadsafe.

require 'singleton'

module Wisper
  class Registration
    class Tracer
      include Singleton

      attr_reader :logs, :enabled

      def initialize
        @logs = []
        @enabled = false
      end

      def enabled?
        enabled
      end

      def enable
        @enabled = true
        ObjectRegistration.class_eval do
          def before_broadcast(event)
            tracer.log(:publisher => publisher.class.to_s,
                       :event => event,
                       :listener => listener.class.to_s,
                       :async => async)
          end

          def tracer
            Wisper::Registration::Tracer
          end
        end
      end

      def disable
        logs.clear
        @enabled = false
      end

      def log(details)
        logs << details if enabled?
      end

      def self.enable
        instance.enable
      end

      def self.disable
        instance.disable
      end

      def self.enabled?
        instance.enabled?
      end

      def self.log(details)
        instance.log(details)
      end

      def self.logs
        instance.logs
      end
    end
  end
end
