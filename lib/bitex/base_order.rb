module Bitex
  # Base class for Bids and Asks
  class BaseOrder
    # @!attribute id
    #   @return [Integer] This Bid's unique ID.
    attr_accessor :id

    # @!attribute created_at
    #   @return [Time] Time when this Bid was created.
    attr_accessor :created_at

    # @!attribute order_book
    #   @return [Symbol] :btc_usd or :btc_ars
    attr_accessor :order_book

    # @!attribute price
    #   @return [BigDecimal] Maximum price to pay per unit.
    attr_accessor :price

    # @!attribute status
    #  The status in its lifecycle, was defined into Ask/Bid subclass.
    attr_accessor :status

    # @!attribute reason
    #  The cancellation reason for your Ask/Bid subclass, if any.
    #  * :not_cancelled Has not been cancelled.
    #  * :not_enough_funds Not enough funds to place this order.
    #  * :user_cancelled Cancelled per user's request
    #  * :system_cancelled Bitex cancelled this order, for a good reason.
    attr_accessor :reason

    # @!attribute issuer
    #   @return [String] The issuer of this order, helps you tell apart orders created from the web UI and the API.
    attr_accessor :issuer

    # Returns an array with all your active orders of this type and another order of this type that was active the last 2 hours.
    # Uses {Order.all} under the hood.
    def self.all
      Order.all.select { |o| o.is_a?(self) }
    end

    # Returns an array with all your active orders of this type.
    # Uses {Order.active} under the hood.
    def self.active
      Order.active.select { |o| o.is_a?(self) }
    end

    # Find an order in your list of active orders.
    # Uses {Order.active} under the hood.
    def self.find(id)
      from_json(Api.private(:get, "/private#{base_path}/#{id}"))
    end

    # @visibility private
    def self.create!(order_book, amount, price, wait = false)
      order_book_id = ORDER_BOOKS[order_book]
      raise UnknownOrderBook, "Could not find order book #{order_book}" unless order_book_id

      params = { amount: amount, price: price, orderbook: order_book_id }

      order = from_json(Api.private(:post, "/private#{base_path}", params))
      retries = 0
      while wait && order.status == :received
        sleep(0.2)
        order = find_order(order)
        retries += 1
        # Wait 15 minutes for the order to be accepted.
        raise StandardError, "Timed out waiting for #{base_path} ##{order.id}" if retries > 5000
      end
      order
    end

    def cancel!
      path = "/private#{self.class.base_path}/#{id}/cancel"
      self.class.from_json(Api.private(:post, path), self)
    end

    # @visibility private
    def self.from_json(json, order = nil)
      Api.from_json(order || new, json) do |thing|
        thing.order_book = order_books[json[3]]
        thing.price = json[6].to_s.to_d
        thing.status = statuses[json[7]]
        thing.reason = reasons[json[8]]
        thing.issuer = json[10]
      end
    end

    def self.find_order(order)
      find(order.id)
    rescue StandardError
      order
    end

    def self.order_books
      ORDER_BOOKS.invert
    end

    def self.reasons
      { 0 => :not_cancelled, 1 => :not_enough_funds, 2 => :user_cancelled, 3 => :system_cancelled }
    end

    def self.statuses
      { 1 => :received, 2 => :executing, 3 => :cancelling, 4 => :cancelled, 5 => :completed }
    end

    private_class_method :find_order, :order_books, :reasons, :statuses
  end
end
