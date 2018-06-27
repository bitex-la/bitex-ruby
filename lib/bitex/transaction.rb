module Bitex
  # Utility class for fetching an heterogeneous list of objects that compose your transaction history.
  #
  class Transaction
    # @return
    #   [Array<Bitex::Bid, Bitex::Ask, Bitex::SpecieDeposit, Bitex::SpecieWithdrawal, Bitex::UsdDeposit, Bitex::UsdWithdrawal>]
    #   Returns an heterogeneous array with all your transactions for the past 15 days sorted by descending date.
    # @see https://bitex.la/developers#user-account-summary
    def self.all
      Api.private(:GET, '/account_summary').map { |t| Api.deserialize(t) }
    end
  end
end
