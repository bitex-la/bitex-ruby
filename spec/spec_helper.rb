require 'bundler/setup'
Bundler.setup

require 'bitex'
require 'byebug'
require 'webmock/rspec'
require 'shoulda/matchers'
require 'timecop'

Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

RSpec.configure do |config|
  config.include RequestStubs

  config.mock_with :rspec do |mocks|
    mocks.yield_receiver_to_any_instance_implementation_blocks = true
    mocks.syntax = %i[expect should]
  end

  config.expect_with :rspec do |c|
    c.syntax = %i[expect should]
  end

  config.after(:each) do
    Timecop.return
  end

  config.order = 'random'
end
