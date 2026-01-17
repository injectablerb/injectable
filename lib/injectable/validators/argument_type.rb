module Injectable
  module Validators
    # Validate the value of the argument matches the provided type
    # @name => of the argument
    # @type => expected class of the value, or Array of available classes for the value
    # @value => the object of validation
    #
    # @returns nil if all is right
    # raises RuntimeError when problems are found
    class ArgumentType
      class << self
        def validate!(name, type = nil, value = nil)
          return if type.nil?
          return if value.nil?

          case type
          when Module then validate_type(name, type, value)
          when Array then validate_type_in_array(name, type, value)
          else
            raise wrong_type_message(name)
          end
        end

        private

        def validate_type(name, type, value)
          return if value.is_a?(type)

          raise bad_type_message(name, value.class, type)
        end

        def validate_type_in_array(name, types, value)
          return if types.any? { |t| value.is_a?(t) }

          raise bad_type_array_message(name, value.class, types)
        end

        def bad_type_message(name, value_class, expected)
          "argument #{name} passed is a #{value_class}, needs to be a #{expected}"
        end

        def wrong_type_message(name)
          ":type for argument #{name} must be a Class, a Module or an Array of Classes or Modules"
        end

        def bad_type_array_message(name, value_class, expected)
          "argument #{name} passed is a #{value_class}, needs to be a #{expected.join(' or ')}"
        end
      end
    end
  end
end
