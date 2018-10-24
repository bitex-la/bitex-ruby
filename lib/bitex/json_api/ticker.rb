module Bitex
  module JsonApi
    # Overview of current market prices and trade volume, including Volume-Weighted Average Price.
    class Ticker < Base
      # GET /api/tickers
      #
      # Get Tickers of all available markets
      #
      # @return JsonApiClient::ResultSet. It has the server response.
      # self.all
      def self.all
        super[0]
      end

      # GET /api/tickers/:orderbook_code
      #
      # Get the ticker of a market.
      #
      # @param [Symbol] orderbook_code. Values: :btc_usd, :btc_ars, :bch_usd, :btc_pyg, :btc_clp, :btc_uyu
      #
      # @return JsonApiClient::ResultSet. It has the server response data, and in its only element, market parsed to json api.
      def self.find(orderbook_code)
        raise UnknownOrderbook unless valid_code?(orderbook_code)

        super(orderbook_code)[0]
      end

      # @param [Symbol] orderbook_code. Values: :btc_usd, :btc_ars, :bch_usd, :btc_pyg, :btc_clp, :btc_uyu
      #
      # @return [true] if orderbook code is valid.
      def self.valid_code?(orderbook_code)
        ORDERBOOKS.include?(orderbook_code)
      end

      private_class_method :valid_code?
    end
  end
end
