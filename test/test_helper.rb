ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

module GeneralUtilitiesHelper
  def json_to_hwia(json_string)
    JSON.parse(json_string).with_indifferent_access
  end
end

class ActionDispatch::IntegrationTest
  include GeneralUtilitiesHelper
end
