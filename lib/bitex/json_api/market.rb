module Bitex
  module JsonApi
    # Our public market data endpoints let anyone check our market's volume, prices and transaction history.
    # It also provides aggregateted candlestick-like data points for the last 24 hours, 7 days and 30 days of trading.
    # You don't need an API key (or even sign up to Bitex) to access the public market data.
    class Market < Base
      # GET /api/markets/:orderbook_code
      #
      # Get full information of market.
      # If you want only some of the fields provided, you can specify which fields to include by using the `include` query param.
      #   Possible values are: bids, asks, transactions and candles.
      # See the example to get only the orderbook data (bids and asks).
      # If you require more information other than the default, take a look at the endpoints
      #   /api/markets/:orderbook_code/transactions and /api/markets/:orderbook_code/candles respectively.
      # To get all possible orderbook_codes check Orderbooks.
      #
      # @param order_book_code[Symbol] [:btc_ars, :btc_clp, :btc_pyg, :btc_usd, :btc_uyu]
      # @param resources[Symbol] [:bids, :asks, :candles, :transactions]
      def self.find(order_book_code, *resources)
        request(:public) { includes(*resources).find(order_book_code) }
      end

      # GET /api/markets/:orderbook_code/transactions
      #
      # Get last transactions of a given market.
      # This endpoint supports 1 additional parameter (set as query param):
      # filter:
      #   from: number of hours from where you want the transactions to be retrieved. default = 1
      #
      # @param order_book_code[Symbol] [:btc_ars, :btc_clp, :btc_pyg, :btc_usd, :btc_uyu]
      # @param from[Integer] [1..+]
      def self.transactions(order_book_code, from: nil)
        params = { market_id: order_book_code }.tap { |hash| hash.merge!(from: from) if from.present? }
        request(:public) { Transaction.where(params).all }
      end

      # GET /api/markets/:orderbook_code/candles
      #
      # Get candles for a given market.
      # This endpoint supports 2 additional parameters (set as query params):
      #   filter:
      #     from: number of days from where you want the candles to be. default = 1
      #   Query param:
      #     span: timespan for each candle. default = 1
      #
      # @param order_book_code[Symbol] [:btc_ars, :btc_clp, :btc_pyg, :btc_usd, :btc_uyu]
      # @param from[Integer] [1..+]
      # @param span[Integer] [1..+]
      def self.candles(order_book_code, from: nil, span: nil)
        params = { market_id: order_book_code }.tap { |hash| hash.merge!(from: from) if from.present? }
        request(:public) do
          query = Candle.where(params)
          (span.present? ? query.with_params(span: span) : query).all
        end
      end
    end
  end
end
