module Injectable
  module Validators
    # Given a return specification, validates according to its kind
    # @returns nil if all is right
    # raises RuntimeError in case of problems
    class Returns
      class << self
        def validate!(spec, result)
          return unless spec

          kind = spec[:kind]

          case kind
          when :single
            Injectable::Validators::SingleReturns.validate!(*spec.values_at(:type, :nullable), result)
          when :collection
            Injectable::Validators::CollectionReturns.validate!(
              *spec.values_at(:collection_type, :element_type, :nullable, :allow_nils), result
            )
          else
            raise("unknown return spec kind: #{kind}")
          end
        end
      end
    end
  end
end
