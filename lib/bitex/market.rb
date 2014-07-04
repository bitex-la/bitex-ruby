module Bitex
  # Public market data for a specie, do not use directly, use
  # {BitcoinMarketData} and {LitecoinMarketData} instead.
  class MarketData

    # The species currency ticker conveniently formatted as a ruby Hash with
    # symbolized keys.
    # @see https://bitex.la/developers#ticker
    def self.ticker
      api_get('/market/ticker').symbolize_keys
    end

    # The species order book as a Hash with two keys: bids and asks.
    # Each of them is a list of list consisting of [price, quantity]
    # @see https://bitex.la/developers#order_book
    def self.order_book
      api_get('/market/order_book').symbolize_keys
    end

    # The species transactions for the past hour as a list of lists,
    # each composed of [unix_timestamp, transaction_id, price, quantity]
    # @see https://bitex.la/developers#transactions
    def self.transactions
      api_get('/market/transactions')
    end
    
    # Returns a list of lists with aggregated transaction data for each hour
    # from the last 24 hours.
    # @see https://bitex.la/developers#last_24_hours
    def self.last_24_hours
      api_get('/market/last_24_hours')
    end

    # Returns a list of lists with aggregated transaction data for each 4 hour
    # period from the last 7 days.
    # @see https://bitex.la/developers#last_7_days
    def self.last_7_days
      api_get('/market/last_7_days')
    end

    # Returns a list of lists with aggregated transaction data for each day
    # from the last 30 days.
    # @see https://bitex.la/developers#last_30_days
    def self.last_30_days
      api_get('/market/last_30_days')
    end

    # @visibility private
    def self.api_get(path, options = {})
      Api.public("/#{specie}#{path}", options)
    end
  end

  # A {MarketData} for Bitcoin.
  class BitcoinMarketData < MarketData
    def self.specie
      'btc'
    end
  end

  # A {MarketData} for Litecoin.
  class LitecoinMarketData < MarketData
    def self.specie
      'ltc'
    end
  end
end
