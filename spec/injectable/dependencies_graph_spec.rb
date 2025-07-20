describe Injectable::DependenciesGraph, '#resolve' do
  let(:ns)    { double('Namespace') }
  let(:graph) { described_class.new(namespace: ns) }

  context 'when depending on a dependency not declared' do
    subject { graph.add(name: :something, depends_on: %i[missing none]) }

    it 'raises an exception' do
      message = 'missing dependencies: missing, none'
      expect { subject }.to raise_error Injectable::MissingDependenciesException, message
    end
  end

  describe '#proxy' do
    subject { graph.proxy }

    let(:proxy_class) { double('Proxy class') }
    let(:proxy) { double('Proxy instance') }
    let(:dependency_class) { double('Dependency class') }
    let(:dependency) { double('Dependency instance') }
    let(:graph) do
      described_class.new(namespace: ns,
                          proxy_class: proxy_class,
                          dependency_class: dependency_class)
    end

    let(:name) { :some_name }
    let(:options) { { name: name, depends_on: [] } }

    before do
      allow(dependency_class).to receive(:new).with(options).and_return(dependency)
      allow(proxy_class).to receive(:new).with(graph: { name => dependency }, namespace: ns).and_return(proxy)
      graph.add(**options)
    end

    it { is_expected.to eq proxy }
  end
end
