module Injectable
  module Validators
    # Validate argument declaration options and normalize them.
    # @name => name of the argument
    # @type => declared class or Array of classes for the argument
    # @default => declaration of default value for the argument
    #
    # @return nil if all is good
    # raises ArgumentError when problems are found
    class ArgumentDeclaration
      class << self
        def validate!(name, type = nil, default = nil)
          return if type.nil?

          case type
          when Module then validate_class(name, type, default)
          when Array then validate_array(name, type, default)
          else
            raise(ArgumentError, wrong_type_message(name))
          end
        end

        private

        def validate_class(name, type, default)
          return if default.nil?
          return if default.is_a?(type)

          raise ArgumentError, bad_default_type_message(name, default.class, type)
        end

        def validate_array(name, types, default)
          raise ArgumentError, empty_types_array_message(name) if types.empty?

          array_of_modules = types.all?(Module)
          raise ArgumentError, wrong_types_in_array_message(name) unless array_of_modules
          return if default.nil?

          default_in_array = types.any? { |t| default.is_a?(t) }
          return if default_in_array

          raise ArgumentError, bad_default_type_in_array_message(name, default.class, types)
        end

        def wrong_type_message(name)
          ":type for argument #{name} must be a Class, a Module or an Array of Classes or Modules"
        end

        def bad_default_type_message(name, default_class, type)
          "default for argument #{name} is a #{default_class}, needs to be a #{type}"
        end

        def empty_types_array_message(name)
          ":type for argument #{name} can't be an empty Array"
        end

        def wrong_types_in_array_message(name)
          ":type for argument #{name} is defined as an Array, but its contents are not all Classes or Modules"
        end

        def bad_default_type_in_array_message(name, default_class, types)
          "default for argument #{name} is a #{default_class}, needs to be #{types.join(' or ')}"
        end
      end
    end
  end
end
