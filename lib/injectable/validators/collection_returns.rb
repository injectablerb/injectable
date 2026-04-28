module Injectable
  module Validators
    # Enforces collection type, contents types, and nils are respected
    # @return nil if all is right
    # raises RunTimeError if problems are found
    class CollectionReturns
      class << self
        def validate!(collection_type, element_type, nullable, allow_nils, result)
          if result.nil?
            raise(non_nullable_collection(collection_type, element_type)) unless nullable
          elsif !result.is_a?(collection_type)
            raise(bad_collection_type(result.class, collection_type, element_type))
          else
            result.each_with_index { |e, i| validate(e, allow_nils, element_type, i) }
          end
        end

        private

        def validate(element, allow_nils, element_type, index)
          if element.nil?
            raise("collection contains nil at position #{index} but allow_nils is false") unless allow_nils
          elsif !element.is_a?(element_type)
            raise(bad_element_type(element.class, element_type, index))
          end
        end

        def non_nullable_collection(collection_type, element_type)
          "return value is nil, expected a #{collection_type} of #{element_type}"
        end

        def bad_collection_type(result_class, collection_type, element_type)
          "return value is a #{result_class}, needs to be a #{collection_type} of #{element_type}"
        end

        def bad_element_type(found, expected, index)
          "return collection contains a #{found} at position #{index}, needs elements of #{expected}"
        end
      end
    end
  end
end
