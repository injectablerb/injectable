module Injectable
  module Validators
    # Validate the value of the argument matches the provided type
    # @name => of the argument
    # @type => expected class of the value
    # @value => the object of validation
    #
    # @returns nil if all is right
    # raises RuntimeError when problems are found
    class ArgumentType
      class << self
        def validate!(name, type = nil, value = nil)
          return unless type
          return unless value
          raise bad_type_message(name, value.class, type).to_s unless value.is_a?(type)
        end

        private

        def bad_type_message(name, value_class, expected)
          "argument #{name} passed is a #{value_class}, needs to be a #{expected}"
        end
      end
    end
  end
end
