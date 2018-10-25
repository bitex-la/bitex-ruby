module Bitex
  module JsonApi
    # This resource groups together your bids and asks to get and cancel them altogether.
    class Order < Base
      # GET /api/orders
      #
      # Get Bids & Asks with :executing status
      #
      # return [Array<Order>]
      def self.all
        private_request { super() }
      end

      custom_endpoint :'all/cancel', on: :collection, request_method: :post
      # POST /api/orders/cancel
      #
      # This action represents an intention to cancel all your orders.
      # Despite of this endpoint responding with a 204 status, the order may not have been cancelled if it was previously matched.
      # In order to check the status of the order, you can query all your active orders with the /api/orders endpoint.
      #
      # return [Array] empty.
      def self.cancel_all!
        private_request { send(:'all/cancel') }
      end


      custom_endpoint :cancel, on: :collection, request_method: :post
      # POST /api/orders/:orderbook_code/cancel
      #
      # This action represents an intention to cancel an order from a specific orderbook.
      #
      # return [Array] empty.
      def self.cancel!(orderbook_code:)
        raise UnknownOrderbook unless valid_code?(orderbook_code)

        private_request { cancel(id: orderbook_code) }
      end

      # @param [Symbol] orderbook_code. Values: :btc_usd, :btc_ars, :bch_usd, :btc_pyg, :btc_clp, :btc_uyu
      #
      # @return [true] if orderbook code is valid.
      def self.valid_code?(orderbook_code)
        ORDERBOOKS.include?(orderbook_code)
      end
    end
  end
end
