$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bundler/setup'
Bundler.setup

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'rake'
require 'pry'
require 'stub_env'
require 'snap_ci_manual_trigger'

RSpec.configure do |config|
  config.include StubEnv::Helpers
end