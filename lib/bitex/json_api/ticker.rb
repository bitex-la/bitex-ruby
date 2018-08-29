module Bitex
  module JsonApi
    # Overview of current market prices and trade volume, including Volume-Weighted Average Price.
    class Ticker < Base
      # GET /api/tickers/:orderbook_code
      #
      # Get the ticker of a market.
      #
      # @param [Symbol] order_book_code. Values: :btc_ars, :btc_clp, :btc_pyg, :btc_usd, :btc_uyu.
      #
      # @return JsonApiClient::ResultSet. It has the server response data, and in its only element, market parsed to json api.
      def self.find(order_book_code)
        raise UnknownOrderBook unless valid_code?(order_book_code)

        request(:public) { super(order_book_code) }
      end

      # @param [Symbol] order_book_code. Values: :btc_ars, :btc_clp, :btc_pyg, :btc_usd, :btc_uyu
      #
      # @return [true] if order book code is valid.
      def self.valid_code?(order_book_code)
        ORDER_BOOKS.include?(order_book_code)
      end

      private_class_method :valid_code?
    end
  end
end
