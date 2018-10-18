module Bitex
  module JsonApi
    # Abstract class for Bids and Asks.
    # order: [:bids, :asks]
    class OrderGroup < Base
      # POST /api/markets/:orderbook_code/:order
      #
      # @param [Symbol] orderbook_code. Values: Bitex::ORDERBOOKS.keys
      # @param [BigDecimal] amount.
      # @param [BigDecimal] price.
      #
      # See subclass specification.

      # POST /api/markets/:orderbook_code/:order/cancel
      #
      # Schedules a order for cancelation as soon as our Matching Engine unlocks it.
      # It sets the order status to "To be cancelled (3)" immediately,
      # and then you can check your Orders to see when it's actually cancelled.
      #
      # See subclass specification.
      def self.cancel(orderbook_code:, id:)
        where(market_id: orderbook_code).find(id).cancel!
      end

      # @param [Symbol] orderbook_code. Values: :btc_usd, :btc_ars, :bch_usd, :btc_pyg, :btc_clp, :btc_uyu
      #
      # @return [true] if order book code is valid.
      def self.valid_code?(orderbook_code)
        ORDERBOOKS.include?(orderbook_code)
      end

      def self.valid_amount?(amount)
        amount.positive?
      end
    end
  end
end
