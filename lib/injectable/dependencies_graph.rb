require 'forwardable'

module Injectable
  # Holds the dependency signatures of the service object
  class DependenciesGraph
    attr_reader :graph, :dependency_class
    attr_accessor :namespace
    extend Forwardable
    def_delegators :@graph, :[]

    def initialize(namespace:, dependency_class: ::Injectable::Dependency)
      @namespace = namespace
      @graph = {}
      @dependency_class = dependency_class
    end

    def names
      graph.keys
    end

    def with_namespace(namespace)
      dup.tap { |dupe| dupe.namespace = namespace }
    end

    # Adds the signature of a dependency to the graph
    def add(name:, depends_on:, **kwargs)
      check_for_missing_dependencies!(depends_on)
      graph[name] = dependency_class.new(kwargs.merge(name: name, depends_on: depends_on))
    end

    private

    def check_for_missing_dependencies!(deps)
      missing = deps.reject { |dep| graph.key?(dep) }
      return if missing.empty?

      raise Injectable::MissingDependenciesException, "missing dependencies: #{missing.join(', ')}"
    end
  end
end
