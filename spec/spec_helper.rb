# frozen_string_literal: true

require "com_thetrainline"
require_relative "../lib/com_thetrainline/client"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    example = RSpec.current_example
    VCR.insert_cassette(example.metadata[:full_description], record: :new_episodes)
  end

  config.after(:each) do
    VCR.eject_cassette
  end
end
