module Bitex
  # Utility class for fetching an heterogeneous list of objects that
  # compose your transaction history.
  class Trade
    # @return [Array<Bitex::Buy, Bitex::Sell]
    #   Returns an heterogeneous array with all your transactions for the past
    #   30 days sorted by descending date.
    # @see https://bitex.la/developers#user-trades
    def self.all
      Api.private(:GET, '/private/trades').collect{|o| Api.deserialize(o) }
    end
  end
end
