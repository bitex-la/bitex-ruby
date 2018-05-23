module Bitex
  # TODO: rever esta docu
  # A transaction in which you bought some quantity of specie.
  class Buy < Match
    # @!attribute id
    #   @return [Integer] This buy's unique ID.

    # @!attribute created_at
    #   @return [Time] Time when this Buy happened.

    # @!attribute order_book
    #   @return [Symbol] :btc_usd or :btc_ars

    # @!attribute quantity
    #   TODO: rever esta docu
    #   @return [BigDecimal] Quantity of specie bought

    # @!attribute amount
    #   @return [BigDecimal] Amount of USD spent

    # @!attribute fee
    #   TODO: rever esta docu
    #   @return [BigDecimal] Quantity of specie paid as transaction fee.

    # @!attribute price
    #   @return [BigDecimal] Price paid per unit

    # @!attribute bid_id
    #   @return [Integer] Unique ID for the Bid that resulted in this Buy
    attr_accessor :bid_id

    # @visibility private
    def self.from_json(json)
      super(json).tap do |thing|
        thing.bid_id = json[8].to_i
      end
    end
  end
end
