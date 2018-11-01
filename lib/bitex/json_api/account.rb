module Bitex
  module JsonApi
    # These endpoints give you access general information about your account such as your balances, movements including deposits,
    # withdrawals as well as executed bids and asks, and your list of KYC Profiles, a collection of all the people or legal
    # entities associated to your bitex account in any capacity.
    #
    # If you're looking for your individual trades see Your latest Trades.
    # Most accounts only need one KYC Profile, if you need to create sub-accounts have a look at our Reseller API.
    class Account < Base
      # GET /api/accounts
      #
      # Get all your accounts.
      #
      # @return 
      def self.all
        private_request { super }
      end
    end
  end
end
