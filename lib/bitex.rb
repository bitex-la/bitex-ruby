require 'active_support'
require 'active_support/core_ext'
require 'json'
require 'curl'
require 'bigdecimal'
require 'bigdecimal/util'
require 'bitex/match'
require 'bitex/base_order'

Dir[File.expand_path('bitex/*.rb', __dir__)].each { |f| require f }

##
# Documentation here!
#
module Bitex
  mattr_accessor :api_key
  mattr_accessor :sandbox
  mattr_accessor :debug
  mattr_accessor :ssl_version

  ORDER_BOOKS = { btc_usd: 1, btc_ars: 5, btc_pyg: 10, btc_clp: 11, btc_uyu: 12 }
  class UnknownOrderBook < StandardError
  end
end
