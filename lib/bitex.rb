require 'active_support/core_ext'
require 'json'
require 'curl'
require 'bigdecimal'
require 'active_support'
require 'bitex/match'
Dir[File.expand_path("../bitex/*.rb", __FILE__)].each {|f| require f}

module Bitex
  mattr_accessor :api_key
end