module Bitex
  module JsonApi
    # Request a Specie withdrawal to a given address.
    # All Withdrawals are accepted in the 'Received (1)' state, and are moved into the 'Pending (2)' state immediately if you
    # have enough funds, then they're moved the 'Accepted (2)' or 'Rejected (3)' state when processed by our account officials.
    class CoinWithdrawal < Base
      # POST /api/coin_withdrawals
      #
      # Ask for a Cryptocurrency Withdrawal.
      #
      # @param [Symbol] currency: Currently, the possible values are :btc and :bch.
      #
      # @return [CoinWithdrawal>].
      def self.create(label:, amount:, currency:, to_addresses:)
        raise CurrencyError unless valid_currency?(currency)

        private_request { super(label: label, amount: amount, currency: currency, to_addresses: to_addresses) }
      end

      # @param [Symbol] currency. Values: :bch, :btc
      #
      # @return [true] if currency code is valid.
      def self.valid_currency?(currency)
        %i[bch btc].include?(currency)
      end
    end
  end
end
