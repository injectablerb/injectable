require 'spec_helper'
require 'injectable/validators/collection_returns'

describe Injectable::Validators::CollectionReturns do
  describe '.validate!' do
    let(:collection_type) { Array }
    let(:element_type) { Integer }
    let(:nullable_collection) { false }
    let(:allow_nil_elements) { false }
    let(:value) { [1, 2, 3] }

    it 'accepts array of correct elements' do
      expect do
        described_class.validate!(collection_type, element_type, nullable_collection, allow_nil_elements, value)
      end.not_to raise_error
    end

    it 'raises when array contains wrong element type' do
      expect do
        described_class.validate!(collection_type, element_type, nullable_collection, allow_nil_elements, [1, 'a'])
      end.to raise_error(RuntimeError, /return collection contains a String, needs elements of Integer/)
    end

    it 'raises when nil and not nullable' do
      expect do
        described_class.validate!(collection_type, element_type, nullable_collection, allow_nil_elements, nil)
      end.to raise_error(RuntimeError, /return value is nil, expected a Array of Integer/)
    end

    it 'accepts nil when nullable' do
      expect do
        described_class.validate!(collection_type, element_type, true, allow_nil_elements, nil)
      end.not_to raise_error
    end

    it 'raises if collection has nil and allow_nils false' do
      expect do
        described_class.validate!(collection_type, element_type, nullable_collection, allow_nil_elements, [1, nil])
      end.to raise_error(RuntimeError, /collection contains nil but allow_nils is false/)
    end

    it 'accepts nil elements when allow_nils true' do
      expect do
        described_class.validate!(collection_type, element_type, nullable_collection, true, [1, nil])
      end.not_to raise_error
    end

    it 'raises when returned object is not Enumerable or collection class' do
      expect do
        described_class.validate!(collection_type, element_type, nullable_collection, allow_nil_elements, 123)
      end.to raise_error(RuntimeError, /needs to be a Array of Integer/)
    end
  end
end
