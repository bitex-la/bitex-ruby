module Bitex
  # An Ask is an order to sell a given orderbook.
  # @see BaseOrder
  class Ask < BaseOrder
    # @!attribute id
    #   @return [Integer] This Ask's unique ID.

    # @!attribute created_at
    #   @return [Time] Time when this Ask was created.

    # @!attribute orderbook
    #   @return [Symbol] :btc_usd or :btc_ars

    # @!attribute quantity
    # TODO: rever esta documentacion
    #   @return [BigDecimal] Quantity of specie to sell in this Ask.
    attr_accessor :quantity

    # @!attribute remaining_quantity
    # TODO: rever esta documentacion
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
    #  * :user_cancelled Cancelled per user's request.
    #  * :system_cancelled Bitex cancelled this order, for a good reason.

    # @!attribute produced_amount
    #   @return [BigDecimal] Amount of USD produced from this sale
    attr_accessor :produced_amount

    # @!attribute issuer
    #   @return [String] The issuer of this order, helps you tell apart orders created from the web UI and the API.

    # @visibility private
    def self.base_path
      '/asks'
    end

    # TODO: rever esta documentacion
    # Create a new Ask for selling a Quantity of specie charging no less than Price per each.
    # @param orderbook [Symbol] :btc_usd or :btc_ars, whatever you're selling.
    # @param quantity [BigDecimal] Quantity to sell.
    # @param price [BigDecimal] Minimum price to charge when selling.
    # @param wait [Boolean] Block the process and wait until this ask moves out of the :received state, defaults to false.
    # @see https://bitex.la/developers#create-ask
    def self.create!(orderbook, quantity, price, wait = false)
      super
    end

    # @visibility private
    def self.from_json(json, order = nil)
      super(json, order).tap do |thing|
        thing.quantity = (json[4].presence || 0).to_d
        thing.remaining_quantity = (json[5].presence || 0).to_d
        thing.produced_amount = (json[9].presence || 0).to_d
      end
    end
  end
end
