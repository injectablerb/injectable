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

    context 'when type is not a class, module, or array of them' do
      let(:type) { 123 }

      it 'raises an error' do
        expect do
          described_class.validate!(:foo, type, 0)
        end.to raise_error(RuntimeError,
                           /:type for argument foo must be a Class, a Module or an Array of Classes or Modules/)
      end
    end

    context 'when type is an Array of Classes/Modules' do
      let(:type) { [String, Symbol] }

      it 'accepts the array as a valid union type' do
        expect { described_class.validate!(:foo, type, 'jarl') }.not_to raise_error
      end
    end
  end
end
