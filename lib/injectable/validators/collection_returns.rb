module Injectable
  module Validators
    # Enforces collection type, contents types, and nils are respected
    # @return nil if all is right
    # raises RunTimeError if problems are found
    class CollectionReturns
      class << self
        def validate!(collection_type, element_type, nullable, allow_nils, result)
          if result.nil?
            raise(non_nullable_collection(collection_type, element_type).to_s) unless nullable
          elsif !result.is_a?(collection_type)
            raise(bad_collection_type(result.class, collection_type, element_type).to_s)
          else
            result.each { |element| validate(element, allow_nils, element_type) }
          end
        end

        private

        def validate(element, allow_nils, element_type)
          if element.nil?
            raise('collection contains nil but allow_nils is false') unless allow_nils
          elsif !element.is_a?(element_type)
            raise(bad_element_type(element.class, element_type).to_s)
          end
        end

        def non_nullable_collection(collection_type, element_type)
          "return value is nil, expected a #{collection_type} of #{element_type}"
        end

        def bad_collection_type(result_class, collection_type, element_type)
          "return value is a #{result_class}, needs to be a #{collection_type} of #{element_type}"
        end

        def bad_element_type(found, expected)
          "return collection contains a #{found}, needs elements of #{expected}"
        end
      end
    end
  end
end
