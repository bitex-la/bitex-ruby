module Bitex
  module JsonApi
    class Ask < OrderGroup
      belongs_to :market

      # GET /api/markets/:orderbook_code/asks/:id
      #
      # @param [Symbol] orderbook_code. Values: Bitex::ORDERBOOKS.keys
      # @param [String|Integer] id.
      #
      # @return Ask
      def self.find(orderbook_code:, id:)
        raise UnknownOrderbook unless valid_code?(orderbook_code)

        request(:private) { where(market_id: orderbook_code).find(id) }[0]
      end

      # POST /api/markets/:orderbook_code/asks
      #
      # @param [Symbol] orderbook_code. Values: Bitex::ORDERBOOKS.keys
      # @param [BigDecimal] amount.
      # @param [BigDecimal] price.
      #
      # @return Ask
      def self.create(orderbook_code:, amount:, price:)
        raise UnknownOrderbook unless valid_code?(orderbook_code)
        raise InvalidArgument unless valid_amount?(amount)

        # TODO BEGIN make it synchronous and atomic
        order = request(:private) { super(market_id: orderbook_code, amount: amount, price: price) }
        raise OrderNotPlaced unless order.try(:id).present?

        find(orderbook_code: orderbook_code, id: order.id)
      end

      # POST /api/markets/:orderbook_code/asks/cancel
      #
      # This action represents an intention to cancel an Ask.
      # Despite of this endpoint responding with a 204 status, the Ask may not have been cancelled if it was previously matched.
      # In order to check the status of the ask, you can query all your active orders with the /api/orders endpoint.
      #
      # @param [Symbol] orderbook_code. Values: Bitex::ORDERBOOKS.keys
      # @param [Integer] id.
      def self.cancel(orderbook_code, id)
      end
    end
  end
end
