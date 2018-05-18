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
    #   @eturn [Symbol] The status of this withdrawal.
    #   * :received Our engine is checking if you have enough funds.
    #   * :pending your withdrawal was accepted and is being processed.
    #   * :done your withdrawal was processed and it's on its way through the withdrawal channel you chose.
    #   * :cancelled your withdrawal could not be processed.
    attr_accessor :status

    # @!attribute reason
    #   @eturn [Symbol] The reason for cancellation of this withdrawal, if any.
    #   * :not_cancelled
    #   * :insufficient_funds The instruction was received, but you didn't have enough funds available.
    #   * :no_instructions We could not understand the instructions you provided.
    #   * :recipient_unknown we could not issue this withdrawal because you're not the receiving party.
    attr_accessor :reason

    # @!attribute countr
    #   @return [String] ISO country code.
    attr_accessor :country

    # @!attribute currency
    #   @return [String] Currency for this withdrawal.
    attr_accessor :currency

    # @!attribute payment_method
    #   @return [Symbol] The payment method for this withdrawal.
    #   * :international_bank International bank transfer.
    #   * :bb we'll contact you regarding this withdrawal.
    attr_accessor :payment_method

    # @!attribute label
    #   @return [String]
    attr_accessor :label

    # @!attribute kyc_profile_id
    #   @return [Integer]
    attr_accessor :kyc_profile_id

    # @!attribute instructions
    #   @return [String]
    attr_accessor :instructions

    # @visibility private
    # rubocop:disable Metrics/AbcSize
    def self.from_json(json)
      Api.from_json(new, json) do |usd_withdrawal|
        usd_withdrawal.amount = (json[3].presence || 0).to_d
        usd_withdrawal.status = statuses[json[4]]
        usd_withdrawal.reason = reasons[json[5]]
        usd_withdrawal.country = json[6]
        usd_withdrawal.currency = json[7]
        usd_withdrawal.payment_method = payment_methods[json[8]]
        usd_withdrawal.label = json[9]
        usd_withdrawal.kyc_profile_id = json[10]
        usd_withdrawal.instructions = json[11]
      end
    end
    # rubocop:enable Metrics/AbcSize

    def self.create!(country, amount, currency, method, instructions, label, profile = nil)
      from_json(
        Api.private(
          :post,
          base_url,
          country: country, amount: amount, currency: currency, payment_method: method, instructions: instructions, label: label,
          kyc_profile_id: profile
        )
      )
    end

    def self.find(id)
      from_json(Api.private(:get, "#{base_url}/#{id}"))
    end

    def self.all
      Api.private(:get, base_url).map { |sw| from_json(sw) }
    end

    private_class_method

    def self.base_url
      '/private/usd/withdrawals'
    end

    def self.payment_methods
      { 1 => :bb, 2 => :international_bank }
    end

    def self.reasons
      { 0 => :not_cancelled, 1 => :insufficient_funds, 2 => :no_instructions, 3 => :recipient_unknown }
    end

    def self.statuses
      { 1 => :received, 2 => :pending, 3 => :done, 4 => :cancelled }
    end
  end
end
