module Bitex
  module JsonApi
    # Request a cash  withdrawal from your bitex balance.
    # You only need to set the amount and refer us to a previously created Withdrawal Instruction which specifies a domestic or
    # international bank account, beneficiary details, etc.
    # See the Withdrawal Instructions endpoints to learn more about them, and the available countries and withdrawal methods.
    #
    # All Withdrawals are accepted in the 'Received (1)' state, and are moved into the 'Pending (2)' state immediately if you
    # have enough funds, then they're moved the 'Accepted (2)' or 'Rejected (3)' state when processed by our account officials.
    class CashWithdrawal < Base
      has_one :withdrawal_instruction

      # POST /api/cash_withdrawals
      #
      # You must create the instructions previously with the Withdrawal Instructions endpoint, and then just reference it in the
      # relationships attribute.
      #
      # @return [WithdrawalInstruction]
      def self.create(amount:, fiat:, withdrawal_instruction_id:, otp:)
        new(amount: amount, fiat: fiat).tap do |withdrawal|
          withdrawal.relationships.withdrawal_instruction = WithdrawalInstruction.new(id: withdrawal_instruction_id)
          private_request(otp: otp) { withdrawal.save }
        end
      end
    end
  end
end
