lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'injectable/version'

Gem::Specification.new do |spec|
  spec.name          = 'injectable'
  spec.version       = Injectable::VERSION
  spec.authors       = %w[Papipo iovis jantequera amrocco rewritten]
  spec.email         = %w[dev@rubiconmd.com]

  spec.summary       = 'A library to help you build nice service objects with dependency injection.'
  spec.homepage      = 'https://github.com/rubiconmd/injectable'
  spec.license       = 'MIT'

  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.2'

  spec.add_development_dependency 'bundler', '~> 2.7'
  spec.add_development_dependency 'pry-byebug', '~> 3.11'
  spec.add_development_dependency 'rake', '~> 13.3'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rubocop', '~> 1.78'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.6'
end
