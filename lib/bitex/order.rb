module Bitex
  # Convenience class for fetching heterogeneous lists with all your Bids and Asks.
  class Order
    # @return [Array<Bitex::Bid, Bitex::Ask>] Returns an heterogeneous array with all your active orders and any other order that
    #   was active in the last 2 hours.
    # @see https://bitex.la/developers#orders
    def self.all
      Api.private(:GET, '/private/orders').map { |response| Api.deserialize(response) }
    end

    # @return [Array<Bitex::Bid, Bitex::Ask>] Returns an heterogeneous array with all your active orders.
    # @see https://bitex.la/developers#active-orders
    def self.active
      Api.private(:GET, '/private/orders/active').map { |response| Api.deserialize(response) }
    end
  end
end
