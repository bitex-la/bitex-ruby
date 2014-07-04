module Bitex
  # Utility class for fetching an heterogeneous list of objects that
  # compose your transaction history.
  class Transaction 
    # @return [Array<Bitex::Buy, Bitex::Sell, Bitex::SpecieDeposit,
    #   Bitex::SpecieWithdrawal, Bitex::UsdDeposit, Bitex::UsdWithdrawal>]
    #   Returns an heterogeneous array with all your transactions for the past
    #   30 days sorted by descending date.
    # @see https://bitex.la/developers#user-transactions
    def self.all
      Api.private(:GET, '/private/transactions').collect{|o| Api.deserialize(o) }
    end
  end
end
