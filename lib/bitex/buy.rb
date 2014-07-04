module Bitex
  # A transaction in which you bought some quantity of specie.
  class Buy < Match
    # @!attribute id
    #   @return [Integer] This buy's unique ID.

    # @!attribute created_at
    #   @return [Time] Time when this Buy happened.

    # @!attribute specie
    #   @return [Symbol] :btc or :ltc
    
    # @!attribute quantity
    #   @return [BigDecimal] Quantity of specie bought
    
    # @!attribute amount
    #   @return [BigDecimal] Amount of USD spent

    # @!attribute fee
    #   @return [BigDecimal] Quantity of specie paid as transaction fee.
    
    # @!attribute price
    #   @return [BigDecimal] Price paid per unit
  end
end
