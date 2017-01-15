require 'json_spec'
require 'timecop'

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.include JsonSpec::Helpers
  RSpec::Matchers.alias_matcher :eq_json, :be_json_eql
end

JsonSpec.configure do
  exclude_keys
end
