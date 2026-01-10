module Injectable
  module Validators
    # Validate argument declaration options and normalize them.
    # @name => name of the argument
    # @type => declared class for the argument
    # @default => declaration of default value for the argument
    #
    # @return nil if all is good
    # raises ArgumentError when problems are found
    class ArgumentDeclaration
      class << self
        def validate!(name, type = nil, default = nil)
          return unless type

          raise(ArgumentError, wrong_type_message(name)) unless type.is_a?(Module)
          return unless default

          raise ArgumentError, bad_default_type_message(name, default.class, type) unless default.is_a?(type)
        end

        private

        def wrong_type_message(name)
          ":type for argument #{name} must be a Class or Module"
        end

        def bad_default_type_message(name, default_class, type)
          "default for argument #{name} is a #{default_class}, needs to be a #{type}"
        end
      end
    end
  end
end
