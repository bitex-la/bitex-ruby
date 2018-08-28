module Bitex
  module JsonApi
    # Returns a list representing all individual trades for the past given hours, sorted by descending date.
    class Transaction < Base
      belongs_to :market
    end
  end
end
