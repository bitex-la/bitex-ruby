module Bitex
  module JsonApi
    # Returns a transaction list data for each hour for the last given hours.
    class Candle < Base
      belongs_to :market
    end
  end
end
