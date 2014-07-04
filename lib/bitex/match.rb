module Bitex
  # @visibility private
  # Both Buy and Sell are a kind of Match, they deserialize the same
  # and have very similar fields, although their documentation may differ.
  class Match
    attr_accessor :id
    attr_accessor :created_at
    attr_accessor :specie
    attr_accessor :quantity
    attr_accessor :amount
    attr_accessor :fee
    attr_accessor :price

    # @visibility private
    def self.from_json(json)
      Api.from_json(new, json, true) do |thing|
        thing.quantity = BigDecimal.new(json[4].to_s)
        thing.amount = BigDecimal.new(json[5].to_s)
        thing.fee = BigDecimal.new(json[6].to_s)
        thing.price = BigDecimal.new(json[7].to_s)
      end   
    end
  end
end
