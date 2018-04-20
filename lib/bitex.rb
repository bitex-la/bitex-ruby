require 'active_support'
require 'active_support/core_ext'
require 'json'
require 'curl'
require 'bigdecimal'
require 'bigdecimal/util'
require 'bitex/match'
require 'bitex/order_base'

Dir[File.expand_path('bitex/*.rb', __dir__)].each { |f| require f }

##
# Documentation here!
#
module Bitex
  mattr_accessor :api_key
  mattr_accessor :sandbox
  mattr_accessor :debug
  mattr_accessor :ssl_version
end
