module Bitex
  module JsonApi
    class Market < Base
      # GET /api/markets/:orderbook_code, [:btc_ars, :btc_clp, :btc_pyg, :btc_usd, :btc_uyu]
      # TODO check query
      def self.find(orderbook_code)
        super(orderbook_code).tap do |market|
          market.relationships.candles = candles(orderbook_code)
          market.relationships.transactions = transactions(orderbook_code)
        end
      end

      # GET /api/markets/:orderbook_code/transactions
      # TODO como formo esta uri => /api/markets/btc_usd/transactions?from=24
      def self.transactions(orderbook_code, from: nil)
        Transaction.where(market_id: orderbook_code).all
      end

      # GET /api/markets/:orderbook_code/candles
      # TODO  como formo esta uri => /api/markets/btc_usd/candles?from=7&span=24
      def self.candles(orderbook_code, from: nil, span: nil)
        Candle.where(market_id: orderbook_code).all
      end

      def self.bids(orderbook_code)
        find(orderbook_code).bids
      end

      def self.asks(orderbook_code)
        find(orderbook_code).asks
      end
    end
  end
end
