begin
  require 'celluloid/autostart'
rescue LoadError
end

module Wisper
  class ObjectRegistration < Registration
    attr_reader :with, :async, :tracer, :publisher

    def initialize(listener, options)
      super(listener, options)
      @with  = options[:with]
      @async = options.fetch(:async, false)
      @publisher  = options.fetch(:publisher)
    end

    def broadcast(event, *args)
      method_to_call = map_event_to_method(event)
      if should_broadcast?(event) && listener.respond_to?(method_to_call)
        trace(publisher, event, listener, async)
        unless async
          listener.public_send(method_to_call, *args)
        else
          AsyncListener.new(listener, method_to_call).async.public_send(method_to_call, *args)
        end
      end
    end

    private

    def map_event_to_method(event)
      with || event
    end

    def trace(publisher, event, listener, async)
      return unless tracer.enabled?
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
