module Bitex
  
  # Base class for Bids and Asks
  class OrderBase
    attr_accessor :id
    attr_accessor :created_at
    attr_accessor :specie
    attr_accessor :price
    attr_accessor :status
    attr_accessor :reason

    # Returns an array with all your active orders
    # of this type, and any other order of this type that was active in the
    # last 2 hours. Uses {Order.all} under the hood.
    def self.all
      Order.all.select{|o| o.is_a?(self) }
    end

    # Returns an array with all your active orders of this type
    # Uses {Order.active} under the hood.
    def self.active
      Order.active.select{|o| o.is_a?(self) }
    end
    
    # Find an order in your list of active orders.
    # Uses {Order.active} under the hood.
    def self.find(id)
      from_json(Api.private(:get, "/private#{base_path}/#{id}"))
    end

    # @visibility private
    def self.create!(specie, amount, price, wait=false)
      params = {
        amount: amount,
        price: price,
        specie: {btc: 1, ltc: 2}[specie]
      }
      order = from_json(Api.private(:post, "/private#{base_path}", params))
      retries = 0
      while wait && order.status == :received
        new_order = find(order.id)
        if new_order.nil?
          raise StandardError.new(
            "Order #{base_path} ##{order.id} not found in list")
        end
        order = new_order
        retries += 1
        if retries > 100
          raise StandardError.new(
            "Timed out waiting for #{base_path} ##{order.id}")
        end
        sleep 0.2
      end
      return order
    end
    
    def cancel!
      path = "/private#{self.class.base_path}/#{self.id}/cancel"
      self.class.from_json(Api.private(:post, path), self)
    end
    
    # @visibility private
    def self.from_json(json, order = nil)
      status_lookup = {
        1 => :received,
        2 => :executing,
        3 => :cancelling,
        4 => :cancelled,
        5 => :completed,
      }
      reason_lookup = {
        0 => :not_cancelled,
        1 => :not_enough_funds,
        2 => :user_cancelled,
        3 => :system_cancelled,
      }
      Api.from_json(order || new, json, true) do |thing|
        thing.price = BigDecimal.new(json[6].to_s)
        thing.status = status_lookup[json[7]]
        thing.reason = reason_lookup[json[8]]
      end   
    end
  end
  
  # A Bid is an order to buy a given specie.
  # @see OrderBase
  class Bid < OrderBase
    # @!attribute id
    #   @return [Integer] This Bid's unique ID.

    # @!attribute created_at
    #   @return [Time] Time when this Bid was created.

    # @!attribute specie
    #   @return [Symbol] :btc or :ltc
    
    # @!attribute amount
    #   @return [BigDecimal] Amount of USD to spend in this Bid.
    attr_accessor :amount

    # @!attribute remaining_amount
    #   @return [BigDecimal] Amount of USD left to be spent in this Bid.
    attr_accessor :remaining_amount

    # @!attribute price
    #   @return [BigDecimal] Maximum price to pay per unit.

    # @!attribute status
    #  The status of this Bid in its lifecycle.
    #  * :received queued to check if you have enough funds.
    #  * :executing available in our ourderbook waiting to be matched.
    #  * :cancelling To be cancelled as soon as our trading engine unlocks it.
    #  * :cancelled no further executed. May have some Remaining Amount.
    #  * :completed Fully executed, Remaining Amount should be 0.

    # @!attribute reason
    #  The cancellation reason for this Bid, if any.
    #  * :not_cancelled Has not been cancelled.
    #  * :not_enough_funds Not enough funds to place this order.
    #  * :user_cancelled Cancelled per user's request
    #  * :system_cancelled Bitex cancelled this order, for a good reason.

    # @visibility private
    def self.base_path
      '/bids'
    end

    # Create a new Bid for spending Amount USD paying no more than
    # price per unit.
    # @param specie [Symbol] :btc or :ltc, whatever you're buying.
    # @param amount [BigDecimal] Amount to spend buying.
    # @param price [BigDecimal] Maximum price to pay per unit.
    # @param wait [Boolean] Block the process and wait until this
    #   bid moves out of the :received state, defaults to false.
    # @see https://bitex.la/developers#create-bid
    def self.create!(specie, amount, price, wait=false)
      super
    end
    
    # @visibility private
    def self.from_json(json, order = nil)
      super(json, order).tap do |thing|
        thing.amount = BigDecimal.new(json[4].to_s)
        thing.remaining_amount = BigDecimal.new(json[5].to_s)
      end
    end
  end

  # An Ask is an order to sell a given specie.
  # @see OrderBase
  class Ask < OrderBase
    # @!attribute id
    #   @return [Integer] This Ask's unique ID.

    # @!attribute created_at
    #   @return [Time] Time when this Ask was created.

    # @!attribute specie
    #   @return [Symbol] :btc or :ltc
    
    # @!attribute quantity
    #   @return [BigDecimal] Quantity of specie to sell in this Ask.
    attr_accessor :quantity

    # @!attribute remaining_quantity
    #   @return [BigDecimal] Quantity of specie left to sell in this Ask.
    attr_accessor :remaining_quantity

    # @!attribute price
    #   @return [BigDecimal] Minimum price to charge per unit.

    # @!attribute status
    #  The status of this Ask in its lifecycle.
    #  * :received queued to check if you have enough funds.
    #  * :executing available in our ourderbook waiting to be matched.
    #  * :cancelling To be cancelled as soon as our trading engine unlocks it.
    #  * :cancelled no further executed. May have some Remaining Quantity.
    #  * :completed Fully executed, Remaining Quantity should be 0.

    # @!attribute reason
    #  The cancellation reason of this Ask.
    #  * :not_cancelled Has not been cancelled.
    #  * :not_enough_funds Not enough funds to place this order.
    #  * :user_cancelled Cancelled per user's request
    #  * :system_cancelled Bitex cancelled this order, for a good reason.

    # @visibility private
    def self.base_path
      '/asks'
    end

    # Create a new Ask for selling a Quantity of specie charging no less than
    # Price per each.
    # @param specie [Symbol] :btc or :ltc, whatever you're selling.
    # @param quantity [BigDecimal] Quantity to sell.
    # @param price [BigDecimal] Minimum price to charge when selling.
    # @param wait [Boolean] Block the process and wait until this
    #   ask moves out of the :received state, defaults to false.
    # @see https://bitex.la/developers#create-ask
    def self.create!(specie, quantity, price, wait=false)
      super
    end

    # @visibility private
    def self.from_json(json, order = nil)
      super(json, order).tap do |thing|
        thing.quantity = BigDecimal.new(json[4].to_s)
        thing.remaining_quantity = BigDecimal.new(json[5].to_s)
      end
    end
  end

  # Convenience class for fetching heterogeneous lists with all your Bids and
  # Asks.
  class Order
    # @return [Array<Bitex::Bid, Bitex::Ask>] Returns an heterogeneous array
    #   with all your active orders and any other order that was active in the
    #   last 2 hours.
    # @see https://bitex.la/developers#orders
    def self.all
      Api.private(:GET, '/private/orders').collect{|o| Api.deserialize(o) }
    end

    # @return [Array<Bitex::Bid, Bitex::Ask>] Returns an heterogeneous array
    #   with all your active orders.
    # @see https://bitex.la/developers#active-orders
    def self.active
      Api.private(:GET, '/private/orders/active').collect{|o| Api.deserialize(o) }
    end
  end
end
