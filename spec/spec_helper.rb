$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "beatport_oauth"
require 'vcr'
require 'pry'

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.default_cassette_options = { :record => :new_episodes }
end

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
end
