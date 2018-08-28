module Bitex
  module JsonApi
    # Abstract class for Bids and Asks.
    # order: [:bids, :asks]
    class OrderGroup < Base
      belongs_to :market

      # POST /api/markets/:orderbook_code/:order
      #
      # See subclass specification.
      def self.create(orderbook_code:, amount:, price:)
        where(market_id: orderbook_code).create(amount: amount, price: price)
      end

      # POST /api/markets/:orderbook_code/:order/cancel
      #
      # Schedules a order for cancelation as soon as our Matching Engine unlocks it.
      # It sets the order status to "To be cancelled (3)" immediately,
      # and then you can check your Orders to see when it's actually cancelled.
      def self.cancel(orderbook_code:, id:)
        where(market_id: orderbook_code).find(id).cancel!
      end
    end
  end
end
