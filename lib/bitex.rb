require 'active_support'
require 'active_support/core_ext'

require 'bigdecimal'
require 'bigdecimal/util'

require 'curl'
require 'json'
require 'json_api_client'

require 'bitex/base'
require 'bitex/client'
require 'bitex/forwarder'

require 'bitex/order_group'
Dir[File.expand_path('bitex/order_group/*.rb', __dir__)].each { |f| require f }

Dir[File.expand_path('bitex/*.rb', __dir__)].each { |f| require f }

##
# Documentation here!
#
module Bitex
  mattr_accessor :api_key
  mattr_accessor :sandbox
  mattr_accessor :debug
  mattr_accessor :ssl_version

  ORDERBOOKS = { btc_usd: 1, btc_ars: 5, bch_usd: 8, btc_pyg: 10, btc_clp: 11, btc_uyu: 12 }.freeze

  class UnknownOrderbook < StandardError
  end

  class InvalidArgument < StandardError
  end

  class OrderNotPlaced < StandardError
  end
end
