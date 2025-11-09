require 'forwardable'
require_relative 'support/dependencies'

describe Injectable do
  context 'without defined #call' do
    subject do
      Class.new do
        include Injectable

        def self.to_s
          'MyFancyClass'
        end
      end
    end

    it 'raises an explicit error when using #call' do
      expect { subject.call }.to raise_error(
        NoMethodError,
        'A #call method with zero arity must be defined in MyFancyClass'
      )
    end
  end

  context 'without options' do
    subject do
      Class.new do
        include Injectable

        def call
          'instance #call'
        end
      end
    end

    it 'self.call calls #call on an instance' do
      expect(subject.call).to eq 'instance #call'
    end
  end

  context 'with dependencies' do
    subject do
      Class.new do
        include Injectable

        dependency :third_party do
          'Some third party lib'
        end

        def call
          third_party
        end
      end
    end

    it 'self.call injects default values of dependencies' do
      expect(subject.call).to eq 'Some third party lib'
    end

    it 'allows overriding dependencies' do
      instance = subject.new(third_party: 'Override')
      expect(instance.call).to eq 'Override'
    end
  end

  context 'with dependencies that have plain arguments (not deps) in #initialize' do
    subject do
      Class.new do
        include Injectable

        initialize_with :some_arg, default: 'hardcoded'

        def call
          some_arg
        end
      end
    end

    it 'adds a reader and sets it to a default' do
      expect(subject.call).to eq 'hardcoded'
    end

    it 'supports bypassing the default value' do
      expect(subject.new(some_arg: 'bypass').call).to eq 'bypass'
    end
  end

  context 'with dependencies that have plain arguments (not deps) in #initialize with no default' do
    subject do
      Class.new do
        include Injectable

        initialize_with :some_arg

        def call
          some_arg
        end
      end
    end

    it 'expects the argument to be passed' do
      expect { subject.call }.to raise_error ArgumentError, 'missing keywords: some_arg'
    end

    it 'supports passing a value' do
      expect(subject.new(some_arg: 'bypass').call).to eq 'bypass'
    end
  end

  context 'with dependencies that have a with: array option' do
    subject do
      Class.new do
        include Injectable

        dependency :dep_with_normal_arg, with: ['with: arg']

        def call
          dep_with_normal_arg.somearg
        end
      end
    end

    it 'passes it to the dependency #initialize method' do
      expect(subject.call).to eq 'with: arg'
    end
  end

  context 'with dependencies that have a with: keyword option' do
    subject do
      Class.new do
        include Injectable

        dependency :dep_with_kwargs, with: { somearg: 'with: arg' }

        def call
          dep_with_kwargs.somearg
        end
      end
    end

    it 'passes it to the dependency #initialize method' do
      expect(subject.call).to eq 'with: arg'
    end
  end

  context 'with dependencies that have a with: keyword option and other with array' do
    subject do
      Class.new do
        include Injectable

        dependency :dep_with_both_args, with: ['with: arg', { my_arg: 'with: kwarg' }]

        def call
          dep_with_both_args.to_s
        end
      end
    end

    it 'passes it to the dependency #initialize method' do
      expect(subject.call).to eq 'with: kwarg | with: arg'
    end
  end

  context 'with dependencies that get hashes for both positional args and kwargs' do
    context 'when all args are given' do
      subject do
        Class.new do
          include Injectable

          dependency :dep_with_many_args, with: [
            { arg1_key: 'arg1_value' },
            { arg2_key: 'arg2_value' },
            arg3: 'arg3_value',
            arg4: 'arg4_value'
          ]

          def call
            dep_with_many_args.call
          end
        end
      end

      it 'keeps arguments separate' do
        expect(subject.call).to eq [
          { arg1_key: 'arg1_value' },
          { arg2_key: 'arg2_value' },
          'arg3_value',
          'arg4_value'
        ]
      end
    end

    context 'when a positional arg is skipped' do
      subject do
        Class.new do
          include Injectable

          dependency :dep_with_many_args, with: [
            { arg1_key: 'arg1_value' },
            arg3: 'arg3_value',
            arg4: 'arg4_value'
          ]

          def call
            dep_with_many_args.call
          end
        end
      end

      it 'associates correctly kwargs' do
        expect(subject.call).to eq [
          { arg1_key: 'arg1_value' },
          nil,
          'arg3_value',
          'arg4_value'
        ]
      end
    end

    context 'when kwargs are skipped and last positional is not kwarg-like' do
      subject do
        Class.new do
          include Injectable

          dependency :dep_with_many_args, with: [
            { arg1_key: 'arg1_value' },
            { 'arg2_key' => 'arg2_value' }
          ]

          def call
            dep_with_many_args.call
          end
        end
      end

      it 'keeps positional args as is' do
        expect(subject.call).to eq [
          { arg1_key: 'arg1_value' },
          { 'arg2_key' => 'arg2_value' },
          nil,
          nil
        ]
      end
    end

    context 'when kwargs are skipped and last positional is kwarg-like' do
      subject do
        Class.new do
          include Injectable

          dependency :dep_with_many_args, with: [
            { arg1_key: 'arg1_value' },
            { arg3: 'arg3_value' }
          ]

          def call
            dep_with_many_args.call
          end
        end
      end

      it 'splats last positional arg as kwargs hash' do
        expect(subject.call).to eq [
          { arg1_key: 'arg1_value' },
          nil,
          'arg3_value',
          nil
        ]
      end
    end

    context 'when everything is skipped' do
      subject do
        Class.new do
          include Injectable

          dependency :dep_with_many_args

          def call
            dep_with_many_args.call
          end
        end
      end

      it 'does not add phony kwargs or hashes' do
        expect(subject.call).to eq [
          nil,
          nil,
          nil,
          nil
        ]
      end
    end
  end

  context 'with dependencies that have a call: option' do
    subject do
      Class.new do
        include Injectable
        extend Forwardable

        dependency :some_renderer, call: :render

        def call
          some_renderer.call('hello', kwarg: 'world')
        end
      end
    end

    it 'wraps the specified method in a #call method' do
      expect(subject.call).to eq '#render has been called with hello and world'
    end
  end

  context 'with dependencies that have a call: option and an existing #call method' do
    subject do
      Class.new do
        include Injectable
        extend Forwardable

        dependency :some_callable_renderer, call: :render

        def call
          some_callable_renderer.call('hello', kwarg: 'world')
        end
      end
    end

    it 'raises an exception' do
      expect { subject.call }.to raise_error Injectable::MethodAlreadyExistsException
    end
  end

  context 'with dependencies that have a call: option with a constant' do
    subject do
      Class.new do
        include Injectable

        dependency(:some_constant, call: :name) { Object }

        def call
          some_constant.call
        end
      end
    end

    before do
      subject.call
    end

    it 'does not try to patch the dependency twice' do
      expect(subject.call).to eq 'Object'
    end

    it 'leaves the dependency unpatched' do
      expect(Object).not_to respond_to(:call)
    end
  end

  context 'with plural dependencies' do
    subject do
      Class.new do
        include Injectable

        dependency :chicharrons

        def call
          chicharrons
        end
      end.call
    end

    it { is_expected.to be_a Chicharrons }
  end

  context 'with dependencies without block' do
    subject do
      Class.new do
        include Injectable
        extend Forwardable

        dependency :existing_class
        def_delegators :existing_class, :call
      end
    end

    it 'casts the name to a class and instantiates it' do
      expect(subject.call).to eq 'This has been constantized!'
    end
  end

  context 'with dependencies without block but with :class' do
    subject do
      Class.new do
        include Injectable
        extend Forwardable

        dependency :something_else, class: WeirdName
        def_delegators :something_else, :call
      end
    end

    it 'uses the provided class' do
      expect(subject.call).to eq 'This has been constantized!'
    end
  end

  context 'with arguments' do
    subject do
      Class.new do
        include Injectable

        argument :user_id

        def call
          "Value was #{user_id}"
        end
      end
    end

    it 'allows accessing them with getters' do
      expect(subject.call(user_id: 123)).to eq 'Value was 123'
    end

    it 'requires them' do
      expect { subject.call }.to raise_error(
        ArgumentError,
        'missing keywords: user_id'
      )
    end

    describe 'argument type checking' do
      before do
        class DummyUser; end # rubocop:disable Lint/EmptyClass

        class TypedService
          include Injectable

          argument :user, type: DummyUser, default: nil

          def call
            user
          end
        end

        class StrictService
          include Injectable

          argument :values, type: Array
          def call
            values.to_s
          end
        end
      end

      let(:bad_service) do
        class BadDefaultService
          include Injectable

          argument :report, type: Hash, default: []

          def call
            report
          end
        end
      end

      it 'allows default nil when type is declared' do
        expect { TypedService.call }.not_to raise_error
      end

      it 'sets the value all right' do
        expect(TypedService.call(user: nil).instance_variable_get('@user')).to be_nil
      end

      it 'allows explicit nil when default nil provided and type declared' do
        expect { TypedService.call(user: nil) }.not_to raise_error
      end

      it 'raises ArgumentError when wrong type is passed' do
        expect { StrictService.call(values: 123) }.to raise_error(RuntimeError)
      end

      it 'raises ArgumentError when a declared default does not match the type' do
        expect do
          bad_service
        end.to raise_error(ArgumentError, /default for argument report is a Array, needs to be a Hash/)
      end
    end
  end

  context 'with arguments with default values' do
    subject do
      Class.new do
        include Injectable

        argument :status, default: 'standby'

        def call
          "Value is #{status}"
        end
      end
    end

    it 'allows passing them' do
      expect(
        subject.call(status: 'something_else')
      ).to eq 'Value is something_else'
    end

    it 'sets them to default values if not passed' do
      expect(subject.call).to eq 'Value is standby'
    end
  end

  context 'with recursive dependencies' do
    subject do
      Class.new do
        include Injectable
        extend Forwardable

        dependency :injected_class
        def_delegators :injected_class, :call
      end
    end

    it 'just works' do
      expect(subject.call).to eq 'I got InjectedDep result'
    end
  end

  context 'with depends_on' do
    subject do
      Class.new do
        include Injectable

        dependency :counter
        dependency :somedep, depends_on: :counter
        dependency :anotherdep, depends_on: [:counter]

        def call
          "#{somedep.call}, #{anotherdep.call}"
        end
      end
    end

    it 'shares dependency instances' do
      expect(subject.call).to eq 'Somedep -> 1, Anotherdep -> 2'
    end
  end

  context 'with block dependencies that take dependencies' do
    let(:dep) { double('dep') }

    it 'passes them correctly' do
      expect(BlockyClass.call).to eq "I got 'this is needed'"
    end
  end

  context 'with class inheritance' do
    let(:parent) do
      Class.new do
        include Injectable

        dependency :parent_dep do
          'this comes from parent'
        end

        argument :parent_arg

        def call
          "Returning #{parent_dep} and #{parent_arg}"
        end
      end
    end

    let(:child) do
      Class.new(parent) do
        dependency :child_dep do
          'this is a child dep'
        end
      end
    end

    context 'when calling the child' do
      subject { child.call(parent_arg: 'passed_arg') }

      it { is_expected.to eq 'Returning this comes from parent and passed_arg' }
    end

    context 'adding dependencies to child classes' do
      subject { parent.dependencies.names }

      it { is_expected.not_to include :child_dep }
    end

    context 'with a sibling class' do
      subject { child.call(parent_arg: 'passed_arg') }

      let(:sibling) do
        Sibling = Class.new(parent) do
          argument :required
        end
      end

      it { is_expected.to eq 'Returning this comes from parent and passed_arg' }
    end
  end

  describe 'smart dependency resolution' do
    subject { [Parent.call, Child.call, Sibling.call] }

    it { is_expected.to eq ['in parent', 'in child', 'in sibling'] }
  end

  context 'when the dependency accepts a block' do
    subject do
      Class.new do
        include Injectable

        dependency :callable_block_passer

        def call
          callable_block_passer.call { "can't block this" }
        end
      end
    end

    it 'passes the block to the dependency' do
      expect(subject.call).to eq "can't block this"
    end
  end

  context 'when the dependency accepts a block and has #call aliased' do
    subject do
      Class.new do
        include Injectable

        dependency :runnable_block_passer, call: :run

        def call
          runnable_block_passer.call { "can't block this" }
        end
      end
    end

    it 'passes the block to the dependency' do
      expect(subject.call).to eq "can't block this"
    end
  end

  describe 'return type checking' do
    before do
      class ReturnUser; end # rubocop:disable Lint/EmptyClass

      class ReturnsUserService
        include Injectable

        returns ReturnUser, nullable: false

        def call
          ReturnUser.new
        end
      end

      class ReturnsNilAllowedService
        include Injectable

        returns ReturnUser, nullable: true

        def call
          nil
        end
      end

      class ReturnsNilNotAllowedService
        include Injectable

        returns ReturnUser, nullable: false

        def call
          nil
        end
      end

      class ReturnsWrongTypeService
        include Injectable

        returns ReturnUser, nullable: false

        def call
          123
        end
      end
    end

    it 'allows correct return type' do
      svc = ReturnsUserService.new
      expect { svc.call }.not_to raise_error
    end

    it 'allows nil when allow_nil is true' do
      svc = ReturnsNilAllowedService.new
      expect { svc.call }.not_to raise_error
    end

    it 'raises when nil and nullable is false' do
      svc = ReturnsNilNotAllowedService.new
      expect { svc.call }.to raise_error(RuntimeError, /return value is nil, expected ReturnUser/)
    end

    it 'raises when wrong return type' do
      expect do
        ReturnsWrongTypeService.call
      end.to raise_error(RuntimeError, /return value is a Integer, needs to be a ReturnUser/)
    end

    context 'with collection returns' do
      before do
        class ReturnsArrayClass
          include Injectable

          returns Array, of: ReturnUser, nullable: false, allow_nils: false

          def call
            [ReturnUser.new, ReturnUser.new]
          end
        end

        class ReturnsArrayWithNilsClass
          include Injectable

          returns Array, of: ReturnUser, nullable: false, allow_nils: true

          def call
            [ReturnUser.new, nil, ReturnUser.new]
          end
        end

        class ReturnsWrongTypes
          include Injectable

          returns Array, of: ReturnUser, nullable: false, allow_nils: false

          def call
            [ReturnUser.new, 123]
          end
        end

        class MyCollection
          include Enumerable

          def each
            yield 1, 2
          end
        end

        class ReturnsMyCollection
          include Injectable

          returns MyCollection, of: Integer, nullable: false, allow_nils: false

          def call
            MyCollection.new
          end
        end
      end

      it 'accepts array of declared type' do
        expect { ReturnsArrayClass.call }.not_to raise_error
      end

      it 'accepts nil values if specified' do
        expect { ReturnsArrayWithNilsClass.call }.not_to raise_error
      end

      it 'raises when collection contains wrong types' do
        expect do
          ReturnsWrongTypes.call
        end.to raise_error(RuntimeError, /return collection contains a Integer, needs elements of/)
      end

      it 'accepts any Enumerable (ActiveRecord-like) collection' do
        expect { ReturnsMyCollection.call }.not_to raise_error
      end
    end
  end
end
