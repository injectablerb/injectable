describe Injectable::Validators::ArgumentDeclaration do
  describe '.validate!' do
    subject(:validate!) { described_class.validate!(name, type, default) }

    let(:name) { :foo }
    let(:default) { 1 }
    let(:type) { nil }

    context 'when type is not provided' do
      it { is_expected.to be_nil }
    end

    context 'when type is not a class, module, or array of them' do
      let(:default) { nil }
      let(:type) { 123 }

      it 'raises an error' do
        expect do
          validate!
        end.to raise_error(ArgumentError, /:type for argument foo must be a Class, a Module or an Array/)
      end
    end

    context 'when type is an Array of Classes/Modules and default matches one' do
      let(:type) { [String, Symbol] }
      let(:default) { :bar }

      it { is_expected.to be_nil }
    end

    context 'when type is an Array and default is nil' do
      let(:type) { [String, Symbol] }
      let(:default) { nil }

      it { is_expected.to be_nil }
    end

    context 'when type is an Array and default does not match any' do
      let(:type) { [String, Symbol] }
      let(:default) { 1 }

      it 'raises an error' do
        expect do
          validate!
        end.to raise_error(ArgumentError, /default for argument foo is a Integer, needs to be String or Symbol/)
      end
    end

    context 'when type and default do not match' do
      let(:type) { String }

      it 'raises an error' do
        expect do
          validate!
        end.to raise_error(ArgumentError, /default for argument foo is a Integer, needs to be a String/)
      end
    end

    context 'when type and default match' do
      let(:type) { Integer }

      it { is_expected.to be_nil }
    end
  end
end
