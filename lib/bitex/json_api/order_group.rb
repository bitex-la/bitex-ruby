module Bitex
  module JsonApi
    # TODO request["Authorization"] = 'your_api_key'
    class OrderGroup < Base
      belongs_to :market

      # operations: [:bids, :asks]
      # POST /api/markets/:orderbook_code/:operations # TODO check
      def self.create(orderbook_code:, amount:, price:)
        where(market_id: ordebook_code).create(amount: amount, price: price)
      end

      # POST /api/markets/:orderbook_code/:operations/cancel # TODO check
      def self.cancel(id:)
        where(market_id: ordebook_code).find(id).cancel!
      end
    end
  end
end
