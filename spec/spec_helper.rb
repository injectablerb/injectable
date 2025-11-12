require 'bundler/setup'
require 'injectable'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'simplecov-json'

  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
                                                                    SimpleCov::Formatter::HTMLFormatter,
                                                                    SimpleCov::Formatter::JSONFormatter
                                                                  ])

  SimpleCov.start do
    enable_coverage(:branch)
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
