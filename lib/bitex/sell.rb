module Bitex
  # A transaction in which you sold some quantity of specie.
  class Sell < Match
    # @!attribute id
    #   @return [Integer] This sell's unique ID.

    # @!attribute created_at
    #   @return [Time] Time when this Sell happened.

    # @!attribute order_book
    #   @return [Symbol] :btc_usd or :btc_ars

    # @!attribute quantity
    #   @return [BigDecimal] Quantity of specie sold

    # @!attribute amount
    #   @return [BigDecimal] Amount of USD earned

    # @!attribute fee
    #   @return [BigDecimal] USD amount paid as transaction fee.

    # @!attribute price
    #   @return [BigDecimal] Price charged per unit

    # @!attribute ask_id
    #   @return [Integer] Unique ID for the Ask that resulted in this Sell
    attr_accessor :ask_id

    # @visibility private
    def self.from_json(json)
      super(json).tap do |thing|
        thing.ask_id = json[8].to_i
      end
    end
  end
end
