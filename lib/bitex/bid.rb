module Bitex
  # A Bid is an order to buy a given orderbook.
  # @see BaseOrder
  class Bid < BaseOrder
    # @!attribute id
    #   @return [Integer] This Bid's unique ID.

    # @!attribute created_at
    #   @return [Time] Time when this Bid was created.

    # @!attribute orderbook
    #   @return [Symbol] :btc_usd or :btc_ars

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

    # @!attribute produced_quantity
    #   TODO: rever esta documentacion
    #   @return [BigDecimal] Quantity of specie produced by this bid so far.
    attr_accessor :produced_quantity

    # @!attribute issuer
    #   @return [String] The issuer of this order, helps you tell apart orders created from the web UI and the API.

    # @visibility private
    def self.base_path
      '/bids'
    end

    # Create a new Bid for spending Amount USD paying no more than price per unit.
    # @param orderbook [Symbol] :btc_usd or :btc_ars, whatever you're buying.
    # @param amount [BigDecimal] Amount to spend buying.
    # @param price [BigDecimal] Maximum price to pay per unit.
    # @param wait [Boolean] Block the process and wait until this bid moves out of the :received state, defaults to false.
    # @see https://bitex.la/developers#create-bid
    def self.create!(orderbook, amount, price, wait = false)
      super
    end

    # @visibility private
    def self.from_json(json, order = nil)
      super(json, order).tap do |thing|
        thing.amount = (json[4].presence || 0).to_d
        thing.remaining_amount = (json[5].presence || 0).to_d
        thing.produced_quantity = (json[9].presence || 0).to_d
      end
    end
  end
end
