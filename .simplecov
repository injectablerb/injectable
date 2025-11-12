require 'simplecov-json'

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter
  ]
)

SimpleCov.start do
  enable_coverage(:branch)

  load_profile 'test_frameworks'
end
