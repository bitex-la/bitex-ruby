module Bitex
  # @visibility private
  # Both Buy and Sell are a kind of Match, they deserialize the same and have very similar fields, although their documentation
  # may differ.
  class Match
    attr_accessor :id, :orderbook, :quantity, :amount, :fee, :price, :created_at

    # @visibility private
    def self.from_json(json)
      Api.from_json(new, json) do |thing|
        thing.orderbook = orderbooks[json[3]]
        thing.quantity = json[4].to_s.to_d
        thing.amount = json[5].to_s.to_d
        thing.fee = json[6].to_s.to_d
        thing.price = json[7].to_s.to_d
      end
    end

    private_class_method

    def self.orderbooks
      { 1 => :btc_usd, 5 => :btc_ars }
    end

    def base_coin
      base_quote[0]
    end

    def quote_coin
      base_quote[1]
    end

    private

    def base_quote
      orderbook.upcase.to_s.split('_')
    end
  end
end
