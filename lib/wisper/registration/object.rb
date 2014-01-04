module Wisper
  class ObjectRegistration < Registration
    attr_reader :with, :prefix, :scope

    def initialize(listener, options)
      super(listener, options)
      @with   = options[:with]
      @prefix = stringify_prefix(options[:prefix])
      @scope = options.fetch(:scope, :all)
      fail_on_async if options.has_key?(:async)
    end

    def broadcast(event, publisher, *args)
      method_to_call = map_event_to_method(event)
      if should_broadcast?(event) && listener.respond_to?(method_to_call) && in_scope?(publisher)
        listener.public_send(method_to_call, *args)
      end
    end

    private

    def in_scope?(publisher)
      return true if scope == :all
      publisher.class == scope
    end

    def map_event_to_method(event)
      prefix + (with || event).to_s
    end

    def stringify_prefix(_prefix)
      case _prefix
      when nil
        ''
      when true
        default_prefix + '_'
      else
        _prefix.to_s + '_'
      end
    end

    def default_prefix
      'on'
    end

    def fail_on_async
      raise 'The async feature has been moved to the wisper-async gem'
    end
  end
end
