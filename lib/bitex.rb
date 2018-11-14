require 'active_support'
require 'active_support/core_ext'

require 'bigdecimal'
require 'bigdecimal/util'
require 'string'

require 'curl'
require 'json'
require 'json_api_client'

require 'bitex/client'
require 'bitex/forwarder'
require 'bitex/json_api/base'

require 'bitex/json_api/kyc'
Dir[File.expand_path('bitex/json_api/kyc/*.rb', __dir__)].each { |f| require f }

require 'bitex/json_api/order_group'
Dir[File.expand_path('bitex/json_api/order_group/*.rb', __dir__)].each { |f| require f }

require 'bitex/json_api/trading_bot'
Dir[File.expand_path('bitex/json_api/trading_bot/*.rb', __dir__)].each { |f| require f }

Dir[File.expand_path('bitex/json_api/*.rb', __dir__)].each { |f| require f }

Dir[File.expand_path('bitex/*.rb', __dir__)].each { |f| require f }

# Documentation here!
module Bitex
  ORDERBOOKS = { btc_usd: 1, btc_ars: 5, bch_usd: 8, btc_pyg: 10, btc_clp: 11, btc_uyu: 12 }.freeze

  class UnknownOrderbook < StandardError
  end

  class InvalidArgument < StandardError
  end

  class InvalidResourceArgument < StandardError
  end

  class MalformedOtp < StandardError
  end

  class OrderNotPlaced < StandardError
  end

  class PaymentError < StandardError
  end

  class CurrencyError < StandardError
  end
end
