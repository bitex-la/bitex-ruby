require 'active_support'
require 'active_support/core_ext'
require 'json'
require 'curl'
require 'bigdecimal'
require 'bitex/match'
Dir[File.expand_path("../bitex/*.rb", __FILE__)].each {|f| require f}

module Bitex
  mattr_accessor :api_key
  mattr_accessor :sandbox
  mattr_accessor :debug
  mattr_accessor :ssl_version
end
