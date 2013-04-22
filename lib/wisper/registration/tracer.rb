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
