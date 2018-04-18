module Bitex
  # @visibility private
  # Both Buy and Sell are a kind of Match, they deserialize the same and have very similar fields, although their documentation
  # may differ.
  class Match
    attr_accessor :id, :orderbook, :quantity, :amount, :fee, :price, :created_at

    # @visibility private
    def self.from_json(json)
      Api.from_json(new, json, true) do |thing|
        thing.quantity = json[4].to_s.to_d
        thing.amount = json[5].to_s.to_d
        thing.fee = json[6].to_s.to_d
        thing.price = json[7].to_s.to_d
      end
    end
  end
end
