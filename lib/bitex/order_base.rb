module Bitex
  # Base class for Bids and Asks
  class OrderBase
    attr_accessor :id, :order_book, :price, :status, :reason, :issuer, :created_at

    # Returns an array with all your active orders of this type,
    # and any other order of this type that was active in the last 2 hours.
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
      params = {
        amount: amount,
        price: price,
        order_book: { btc_usd: 1, btc_ars: 5 }[order_book]
      }

      order = from_json(Api.private(:post, "/private#{base_path}", params))
      retries = 0
      while wait && order.status == :received
        sleep 0.2
        begin
          order = find(order.id)
        rescue StandardError
          nil
        end
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
      status_lookup = {
        1 => :received,
        2 => :executing,
        3 => :cancelling,
        4 => :cancelled,
        5 => :completed
      }

      reason_lookup = {
        0 => :not_cancelled,
        1 => :not_enough_funds,
        2 => :user_cancelled,
        3 => :system_cancelled
      }

      Api.from_json(order || new, json, true) do |thing|
        thing.price = json[6].to_s.to_d
        thing.status = status_lookup[json[7]]
        thing.reason = reason_lookup[json[8]]
        thing.issuer = json[10]
      end
    end
  end
end
