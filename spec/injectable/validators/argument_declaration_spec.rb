describe Injectable::Validators::ArgumentDeclaration do
  describe '.validate!' do
    subject(:validate!) { described_class.validate!(name, type, default) }

    let(:name) { :foo }
    let(:default) { 1 }
    let(:type) { nil }

    context 'when type is not provided' do
      it { is_expected.to be_nil }
    end

    context 'when type is not a class or module' do
      let(:default) { nil }
      let(:type) { 123 }

      it 'raises an error' do
        expect { validate! }.to raise_error(ArgumentError, /:type for argument foo must be a Class or Module/)
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
