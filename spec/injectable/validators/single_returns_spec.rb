require 'spec_helper'
require 'injectable/validators/single_returns'

describe Injectable::Validators::SingleReturns do
  describe '.validate!' do
    let(:expected_type) { String }
    let(:nullable) { false }
    let(:value) { 'hello' }

    it 'accepts correct type' do
      expect { described_class.validate!(expected_type, nullable, value) }.not_to raise_error
    end

    it 'raises for wrong type' do
      expect do
        described_class.validate!(expected_type, nullable, 123)
      end.to raise_error(RuntimeError, /needs to be a String/)
    end

    it 'raises for nil when not nullable' do
      expect do
        described_class.validate!(expected_type, nullable, nil)
      end.to raise_error(RuntimeError, /return value is nil, expected String/)
    end

    it 'accepts nil when nullable' do
      expect { described_class.validate!(expected_type, true, nil) }.not_to raise_error
    end
  end
end
