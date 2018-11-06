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
      # @param [String] label: single tag for operation.
      # @param [Float|String] amount: amount to withdraw.
      # @param [String] currency: Currently, the possible values are btc and bch.
      # @param [String] to_address: crypto address to our wallet.
      # @param [String] otp: One Time Password.
      #
      # @return [CoinWithdrawal>].
      def self.create(label:, amount:, currency:, to_addresses:, otp:)
        raise CurrencyError unless valid_currency?(currency)

        private_request(otp: otp) { super(label: label, amount: amount, currency: currency, to_addresses: to_addresses) }
      end

      # @param [String] currency. Values: bch, btc
      #
      # @return [true] if currency code is valid.
      def self.valid_currency?(currency)
        %w[bch btc].include?(currency)
      end

      private_class_method :valid_currency?
    end
  end
end
