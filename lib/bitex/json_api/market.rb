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
      # @param [Symbol] order_book_code. Values: :btc_ars, :btc_clp, :btc_pyg, :btc_usd, :btc_uyu.
      # @param [Array<Symbol>] resources. Values:  [:bids, :asks, :candles, :transactions]
      #
      # @return JsonApiClient::ResultSet. It has the server response data, and in its only element, market parsed to json api.
      def self.find(order_book_code, *resources)
        raise UnknownOrderBook unless valid_code?(order_book_code)
        raise InvalidResourceArgument unless valid_resources?(*resources)

        request(:public) { includes(*resources).find(order_book_code) }
      end

      # GET /api/markets/:orderbook_code/transactions
      #
      # Get last transactions of a given market.
      # This endpoint supports 1 additional parameter (set as query param):
      # filter:
      #   from: number of hours from where you want the transactions to be retrieved. default = 1
      #
      # @param [Symbol] order_book_code. Values: :btc_ars, :btc_clp, :btc_pyg, :btc_usd, :btc_uyu.
      # @param [Integer] from. Values: 1..+
      #
      # @return JsonApiClient::ResultSet. It has the server response data, and all transactions parsed to json api.
      def self.transactions(order_book_code, from: nil)
        raise UnknownOrderBook unless valid_code?(order_book_code)
        raise InvalidArgument unless valid_argument?(from)

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
      # @param [Symbol] order_book_code. Values: :btc_ars, :btc_clp, :btc_pyg, :btc_usd, :btc_uyu
      # @param [Integer] from. Values: 1..+
      # @param [Integer] span. Values: 1..+
      #
      # @return JsonApiClient::ResultSet. It has the server response data, and all candles parsed to json api.
      def self.candles(order_book_code, from: nil, span: nil)
        raise UnknownOrderBook unless valid_code?(order_book_code)
        raise InvalidArgument unless valid_argument?(from) && valid_argument?(span)

        params = { market_id: order_book_code }.tap { |hash| hash.merge!(from: from) if from.present? }
        request(:public) do
          query = Candle.where(params)
          (span.present? ? query.with_params(span: span) : query).all
        end
      end

      # @param [Symbol] order_book_code. Values: :btc_ars, :btc_clp, :btc_pyg, :btc_usd, :btc_uyu
      #
      # @return [true] if order book code is valid.
      def self.valid_code?(order_book_code)
        ORDER_BOOKS.include?(order_book_code)
      end

      # @param [Integer|Float] arg. values: 0..+
      #
      # @return [true] if the argument is not present or if it is numeric and greater than zero.
      def self.valid_argument?(arg)
        return true unless arg.present?
        return false unless arg.is_a?(Numeric)
        arg.positive?
      end

      # @param [Array<Symbol>] resources. values: [:asks, :bids, :candles, :transactions]
      #
      # @return [true] if the argument is not present or if it is numeric and greater than zero.
      def self.valid_resources?(*resources)
        (resources - %i[asks bids candles transactions]).empty?
      end

      private_class_method :valid_code?, :valid_argument?, :valid_resources?
    end
  end
end
