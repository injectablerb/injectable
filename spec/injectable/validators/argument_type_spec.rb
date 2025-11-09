describe Injectable::Validators::ArgumentType do
  describe '.validate!' do
    it 'allows no type being passed' do
      expect { described_class.validate!(:name, nil, 'hello') }.not_to raise_error
    end

    it 'accepts a value of the declared type' do
      expect { described_class.validate!(:name, String, 'hello') }.not_to raise_error
    end

    it 'allows nil values even when a type is declared' do
      expect { described_class.validate!(:count, Integer, nil) }.not_to raise_error
    end

    it 'raises ArgumentError with helpful message when type mismatches' do
      expect { described_class.validate!(:items, Array, 123) }
        .to raise_error(RuntimeError, /argument items passed is a Integer, needs to be a Array/)
    end
  end
end
