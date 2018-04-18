module Bitex
  # A deposit of some specie into your bitex.la balance
  class SpecieDeposit
    # @!attribute id
    #   @return [Integer] This SpecieDeposit's unique ID.
    attr_accessor :id

    # @!attribute created_at
    #   @return [Time] Time when this deposit credited.
    attr_accessor :created_at

    # @!attribute specie
    #   @return [Symbol] :btc
    attr_accessor :specie

    # @!attribute quantity
    #   @return [BigDecimal] Quantity deposited
    attr_accessor :quantity

    # @visibility private
    def self.from_json(json)
      Api.from_json(new, json, true) { |thing| thing.quantity = (json[4] || 0).to_d }
    end

    def self.find(specie, id)
      from_json(Api.private(:get, "/private/#{specie}/deposits/#{id}"))
    end

    def self.all(specie)
      Api.private(:get, "/private/#{specie}/deposits").map { |d| from_json(d) }
    end
  end
end
