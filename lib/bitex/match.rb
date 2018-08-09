module Bitex
  # @visibility private
  # Both Buy and Sell are a kind of Match, they deserialize the same and have very similar fields, although their documentation
  # may differ.
  class Match
    attr_accessor :id, :order_book, :quantity, :amount, :fee, :price, :created_at

    # @visibility private
    # rubocop:disable Metrics/AbcSize
    def self.from_json(json)
      Api.from_json(new, json) do |thing|
        thing.order_book = order_books[json[3]]
        thing.quantity = json[4].to_s.to_d
        thing.amount = json[5].to_s.to_d
        thing.fee = json[6].to_s.to_d
        thing.price = json[7].to_s.to_d
      end
    end
    # rubocop:enable Metrics/AbcSize

    def self.order_books
      ORDER_BOOKS.invert
    end

    private_class_method :order_books

    def base_currency
      base_quote[0]
    end

    def quote_currency
      base_quote[1]
    end

    private

    def base_quote
      order_book.upcase.to_s.split('_')
    end
  end
end
