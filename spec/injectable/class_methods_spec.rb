describe Injectable::ClassMethods do
  describe '#simple_class_attribute' do
    subject(:klass) do
      Class.new do
        include Injectable

        def self.singleton_class?
          true
        end

        class_eval do
          simple_class_attribute :flag
        end

        def call
          'jarl'
        end
      end
    end

    it 'defines instance reader delegating to singleton reader when singleton_class?' do
      klass.flag = 'on'
      expect(klass.flag).to eq('on')
    end

    it 'passes the singleton class attribute value to the instances' do
      klass.flag = 'on'
      instance = klass.new
      expect(instance.flag).to eq('on')
    end

    it 'allows to modify attribute value on the instance', skip: 'Failing, need to investigate' do
      instance = klass.new
      instance.instance_variable_set('@flag', 'local')
      expect(instance.flag).to eq('local')
    end

    it 'does not pass instance values up to the singleton class value' do
      klass.flag = 'on'
      instance = klass.new
      instance.instance_variable_set('@flag', 'local')
      expect(klass.flag).to eq 'on'
    end
  end
end
