module Bitex
  # A withdrawal of USD from your bitex.la balance
  class UsdWithdrawal
    # @!attribute id
    #   @return [Integer] This UsdWithdrawal's unique ID.
    attr_accessor :id

    # @!attribute created_at
    #   @return [Time] Time when this withdrawal was requested by you.
    attr_accessor :created_at

    # @!attribute amount
    #   @return [BigDecimal] Amount withdrawn from your bitex USD balance.
    attr_accessor :amount

    # @!attribute status
    #  Returns the status of this withdrawal.
    #  * :received Our engine is checking if you have enough funds.
    #  * :pending your withdrawal was accepted and is being processed.
    #  * :done your withdrawal was processed and it's on its way through
    #    the withdrawal channel you chose.
    #  * :cancelled your withdrawal could not be processed.
    attr_accessor :status

    # @!attribute reason
    #  Returns the reason for cancellation of this withdrawal, if any.
    #  * :not_cancelled
    #  * :insufficient_funds The instruction was received, but you didn't have enough
    #    funds available
    #  * :no_instructions We could not understand the instructions you provided.
    #  * :recipient_unknown we could not issue this withdrawal because you're
    #    not the receiving party.
    attr_accessor :reason

    # @!attribute countr
    #  Returns ISO country code.
    attr_accessor :country

    # @!attribute currency
    #  Currency for this withdrawal.
    attr_accessor :currency

    # @!attribute payment_method
    #  Returns the payment method for this withdrawal.
    #  * :international_bank International bank transfer
    #  * :bb we'll contact you regarding this withdrawal.
    attr_accessor :payment_method

    # @!attribute label
    attr_accessor :label

    # @!attribute kyc_profile_id
    attr_accessor :kyc_profile_id

    # @!attribute instructions
    attr_accessor :instructions

    # @visibility private
    def self.from_json(json)
      status_lookup = {
        1 => :received,
        2 => :pending,
        3 => :done,
        4 => :cancelled
      }

      reason_lookup = {
        0 => :not_cancelled,
        1 => :insufficient_funds,
        2 => :no_instructions,
        3 => :recipient_unknown
      }

      Api.from_json(new, json) do |thing|
        thing.amount = (json[3].presence || 0).to_d
        thing.status = status_lookup[json[4]]
        thing.reason = reason_lookup[json[5]]
        thing.country = json[6]
        thing.currency = json[7]
        thing.payment_method = json[8]
        thing.label = json[9]
        thing.kyc_profile_id = json[10]
        thing.instructions = json[11]
      end
    end

    def self.create!(country, amount, currency, method, instructions, label, profile = nil)
      from_json(
        Api.private(
          :post,
          '/private/usd/withdrawals',
          country: country,
          amount: amount,
          currency: currency,
          payment_method: method,
          instructions: instructions,
          label: label,
          kyc_profile_id: profile
        )
      )
    end

    def self.find(id)
      from_json(Api.private(:get, "/private/usd/withdrawals/#{id}"))
    end

    def self.all
      Api.private(:get, '/private/usd/withdrawals').map { |sw| from_json(sw) }
    end
  end
end
