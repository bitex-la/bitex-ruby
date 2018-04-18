module Bitex
  # A deposit of some specie into your bitex.la balance
  class SpecieDeposit
    # @!attribute id
    #   @return [Integer] This SpecieDeposit's unique ID.
    attr_accessor :id

    # @!attribute created_at
    #   @return [Time] Time when this deposit credited.
    attr_accessor :created_at

    # @!attribute order_book
    #   @return [Symbol] :btc_usd or :btc_ars
    attr_accessor :order_book

    # @!attribute quantity
    #   @return [BigDecimal] Quantity deposited
    attr_accessor :quantity

    # @visibility private
    def self.from_json(json)
      Api.from_json(new, json, true) { |thing| thing.quantity = json[4].to_s.to_d }
    end

    def self.find(order_book, id)
      from_json(Api.private(:get, "/private/#{order_book}/deposits/#{id}"))
    end

    def self.all(order_book)
      Api.private(:get, "/private/#{order_book}/deposits").map { |d| from_json(d) }
    end
  end
end
