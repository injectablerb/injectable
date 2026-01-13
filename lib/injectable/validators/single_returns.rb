module Injectable
  module Validators
    # Enforces returned type and nullability
    class SingleReturns
      class << self
        def validate!(type, nullable, result)
          if result.nil?
            raise(non_nullable_error_message(type).to_s) unless nullable
          elsif !result.is_a?(type)
            raise(bad_type(type, result.class).to_s)
          end
        end

        private

        def non_nullable_error_message(expected_type)
          "return value is nil, expected #{expected_type}"
        end

        def bad_type(expected_type, result_class)
          "return value is a #{result_class}, needs to be a #{expected_type}"
        end
      end
    end
  end
end
