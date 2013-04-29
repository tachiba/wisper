# Logger for broadcast event. This unlikely to be threadsafe.

require 'singleton'

begin
require 'graphviz'
rescue LoadError
  puts "To use Wisper::Tracer add 'ruby-graphviz' you your Gemfile"
  exit
end


module Wisper
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
          Wisper::Tracer
        end
      end
    end

    def to_s
      logs.map do |details|
        "#{details[:at].strftime('%H:%M:%S')}// #{details[:publisher]} --#{details[:event]}--> #{details[:listener]}"
      end.join("\n")
    end

    def self.to_s
      instance.to_s
    end

    def to_png(target_path)
      graph = GraphViz.new(:G, :type => :digraph)

      publishes   = logs.map { |details| details[:publisher] }.uniq
      listeners   = logs.map { |details| details[:listener] }.uniq

      logs.group_by { |details| details[:publisher] }.each do |pub, details|
        listeners.each do |sub|
          count = details.select { |detail| detail[:listener] == sub }.size
          next if count == 0
          pub_node = graph.add_nodes(pub)
          sub_node = graph.add_nodes(sub)
          pub_node.shape = 'rect'
          graph.add_edges(pub_node, sub_node, :label => count.to_s)
        end
      end

      graph.output(:png => target_path)
    end

    def self.to_png(target_path)
      instance.to_png(target_path)
    end

    def disable
      logs.clear
      @enabled = false
    end

    def log(details)
      logs << details.merge(:at => Time.now) if enabled?
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
