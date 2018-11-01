module Bitex
  module JsonApi
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

      def self.valid_currency?(currency)
        %i[bch btc].include?(currency)
      end
    end
  end
end
