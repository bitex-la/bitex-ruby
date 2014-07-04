module Bitex
  # A transaction in which you sold some quantity of specie.
  class Sell < Match
    # @!attribute id
    #   @return [Integer] This sell's unique ID.

    # @!attribute created_at
    #   @return [Time] Time when this Sell happened.

    # @!attribute specie
    #   @return [Symbol] :btc or :ltc
    
    # @!attribute quantity
    #   @return [BigDecimal] Quantity of specie sold
    
    # @!attribute amount
    #   @return [BigDecimal] Amount of USD earned

    # @!attribute fee
    #   @return [BigDecimal] USD amount paid as transaction fee.
    
    # @!attribute price
    #   @return [BigDecimal] Price charged per unit
  end
end
