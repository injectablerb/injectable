module Injectable
  module ClassMethods
    def self.extended(base)
      base.class_eval do
        simple_class_attribute :dependencies,
                               :call_arguments,
                               :initialize_arguments,
                               :return_spec

        self.dependencies = DependenciesGraph.new(namespace: base)
        self.initialize_arguments = {}
        self.call_arguments = {}
      end
    end

    def inherited(base)
      base.class_eval do
        self.dependencies = dependencies.with_namespace(base)
        self.initialize_arguments = initialize_arguments.dup
        self.call_arguments = call_arguments.dup
      end
    end

    # Blatantly stolen from rails' ActiveSupport.
    # This is a simplified version of class_attribute
    def simple_class_attribute(*attrs)
      attrs.each do |name|
        define_singleton_method(name) { nil }

        ivar = "@#{name}"

        # Define the instance reader immediately when this attribute is declared
        # so instances always respond to the reader even if the singleton
        # class value has not been set yet.
        if singleton_class?
          class_eval do
            define_method(name) do
              if instance_variable_defined? ivar
                instance_variable_get ivar
              else
                singleton_class.send name
              end
            end
          end
        end

        define_singleton_method("#{name}=") do |val|
          singleton_class.class_eval do
            define_method(name) { val }
          end

          val
        end
      end
    end

    # Use the service with the params declared with '.argument'
    # @param args [Hash] parameters needed for the Service
    # @example MyService.call(foo: 'first_argument', bar: 'second_argument')
    def call(args = {})
      new.call(args)
    end

    # Declare dependencies for the service
    # @param name [Symbol] the name of the service
    # @option options [Class] :class The class to use if it's different from +name+
    # @option options [Symbol, Array<Symbol>] :depends_on if the dependency has more dependencies
    # @yield explicitly declare the dependency
    #
    # @return [Object] the injected dependency
    #
    # @example Using the same name as the service object
    #   dependency :team_query
    #     # => @team_query = TeamQuery.new
    #
    # @example Specifying a different class
    #   dependency :player_query, class: UserQuery
    #     # => @player_query = UserQuery.new
    #
    # @example With a block
    #   dependency :active_players do
    #     ->(players) { players.select(&:active?) }
    #   end
    #     # => @active_players = [lambda]
    #
    # @example With more dependencies
    #   dependency :counter
    #   dependency :team_service
    #   dependency :player_counter, depends_on: [:counter, :team_service]
    #     # => @counter = Counter.new
    #     # => @team_service = TeamService.new
    #     # => @player_counter = PlayerCounter.new(counter: @counter, team_service: @team_service)
    #
    # @example Dependencies that don't accept keyword arguments
    #   dependency :counter
    #   dependency :player_counter, depends_on: :counter do |counter:|
    #     PlayerCounter.new(counter)
    #   end
    #     # => @counter = Counter.new
    #     # => @player_counter = PlayerCounter.new(@counter)
    def dependency(name, options = {}, &block)
      options[:block] = block if block_given?
      options[:depends_on] = Array(options.fetch(:depends_on, []))
      options[:name] = name
      dependencies.add(**options)
      define_method name do
        instance_variable_get("@#{name}") || dependencies_proxy.get(name)
      end
    end

    # Declare the arguments for `#call` and initialize the accessors
    # This helps us clean up the code for memoization:
    #
    # ```
    # private
    #
    # def player
    #   # player_id exists in the context because we added it as an argument
    #   @player ||= player_query.call(player_id)
    # end
    # ```
    #
    # Every argument is required unless given an optional default value
    # Option :type can be provided to enforce runtime type checking when the
    # service is called. Example: `argument :user, type: User`.
    # @param name Name of the argument
    # @option options :default The default value of the argument
    # @example
    #   argument :player_id
    #     # => def call(player_id:)
    #     # =>   @player_id = player_id
    #     # => end
    # @example with default arguments
    #   argument :team_id, default: 1
    #     # => def call(team_id: 1)
    #     # =>   @team_id = team_id
    #     # => end)
    def argument(name, options = {})
      Injectable::Validators::ArgumentDeclaration.validate!(name, options[:type], options[:default])

      call_arguments[name] = options
      attr_accessor name
    end

    # Declare the expected return type for the service's `#call` method.
    # Example:
    #   returns User, nullable: false
    # If a return type is declared, the value returned by `#call` will be
    # validated at runtime. If the value is nil and `allow_nil` is false an
    # ArgumentError will be raised. If the value is non-nil and not an
    # instance of the declared type, an ArgumentError will be raised.
    # New returns API
    # Single object:
    #   returns(User, nullable: true/false)
    # Collection:
    #   returns(CollectionClass, of: User, nullable: true/false, allow_nils: true/false)
    def returns(type, of: nil, nullable: false, allow_nils: false)
      spec = { nullable: nullable, allow_nils: allow_nils }

      self.return_spec = if of.nil?
                           spec.merge(initialize_single_return(type))
                         else
                           spec.merge(initialize_collection_return(type, of))
                         end
    end

    def initialize_with(name, options = {})
      initialize_arguments[name] = options
      attr_accessor name
    end

    # Get the #initialize arguments declared with '.initialize_with' with no default
    # @private
    def required_initialize_arguments
      find_required_arguments initialize_arguments
    end

    # Get the #call arguments declared with '.argument' with no default
    # @private
    def required_call_arguments
      find_required_arguments call_arguments
    end

    def find_required_arguments(hash)
      hash.reject { |_arg, options| options.key?(:default) }.keys
    end

    def initialize_single_return(type)
      raise(ArgumentError, ':type for returns must be a Class or Module') unless type.is_a?(Module)

      { kind: :single, type: type }
    end

    def initialize_collection_return(collection_class, element_class)
      raise(ArgumentError, ':of for returns must be a Class or Module') unless element_class.is_a?(Module)
      raise(ArgumentError, ':collection for returns must be a Class or Module') unless collection_class.is_a?(Module)

      unless collection_class.instance_methods.include?(:each)
        raise(ArgumentError,
              "#{collection_class} is not a collection-like class (must respond to :each) when specifying :of")
      end

      { kind: :collection, collection_type: collection_class, element_type: element_class }
    end
  end
end
