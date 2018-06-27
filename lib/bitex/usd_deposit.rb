module Bitex
  # A deposit of USD to your bitex.la balance.
  #
  class UsdDeposit
    # @!attribute id
    #   @return [Integer] This UsdDeposit's unique ID.
    attr_accessor :id

    # @!attribute created_at
    #   @return [Time] Time when this deposit was announced by you.
    attr_accessor :created_at

    # @!attribute requested_amount
    #   @return [BigDecimal] For pre-announced deposits, this is the amount you requested to deposit.
    attr_accessor :requested_amount

    # @!attribute amount
    #   @return [BigDecimal] Final amount credited to your bitex USD balance.
    attr_accessor :amount

    # @!attribute deposit_method
    #   The method used for this deposit
    #   * :astropay
    #   * :other
    attr_accessor :deposit_method

    # @!attribute status
    #  The status of this deposit.
    #  * :pending your deposit notice was received, we're waiting for the funds to credit.
    #  * :done your deposit credited correctly, the funds are available in your balance.
    #  * :cancelled your deposit did not credit, check the 'reason' field.
    attr_accessor :status

    # @!attribute reason
    #  The reason for cancellation of this deposit, if any.
    #  * :not_cancelled.
    #  * :did_not_credit funds never arrived to our end.
    #  * :sender_unknown we could not accept these funds because you're not the sender.
    #  * :other we'll contact you regarding this deposit.
    #  * :user_cancelled We cancelled this deposit per your request.
    attr_accessor :reason

    # @!attribute country
    #  Country of origin for this deposit.
    attr_accessor :country

    # @!attribute currency
    #  Local currency for the country.
    attr_accessor :currency

    # @!attribute kyc_profile_id
    #  KYC profile on whose behalf this deposit is being created.
    attr_accessor :kyc_profile_id

    # @!attribute request_details
    #  Details for our account officers about this deposit.
    attr_accessor :request_details

    # @!attribute astropay_response_body
    #  Response from astropay if selected as the deposit method.
    #  The 'url' field should be the astropay payment url for this deposit.
    attr_accessor :astropay_response_body

    # @!attribute third_party_reference
    #  This deposit's id as issued by the third party payment processor, if any.
    attr_accessor :third_party_reference

    # @visibility private
    # rubocop:disable Metrics/AbcSize
    def self.from_json(json, deposit = nil)
      Api.from_json(deposit || new, json) do |thing|
        thing.requested_amount = (json[3].presence || 0).to_d
        thing.amount = (json[4].presence || 0).to_d
        thing.deposit_method = deposit_methods[json[5]]
        thing.status = statuses[json[6]]
        thing.reason = reasons[json[7]]
        thing.country = json[8]
        thing.currency = json[9]
        thing.kyc_profile_id = json[10]
        thing.request_details = json[11]
        thing.astropay_response_body = json[12]
        thing.third_party_reference = json[13]
      end
    end
    # rubocop:enable Metrics/AbcSize

    def self.create!(country, amount, currency, method, details, profile = nil)
      from_json(
        Api.private(
          :post,
          '/usd/deposits',
          country: country,
          amount: amount,
          currency: currency,
          deposit_method: method,
          request_details: details,
          kyc_profile_id: profile
        )
      )
    end

    def self.find(id)
      from_json(Api.private(:get, "/usd/deposits/#{id}"))
    end

    def cancel!
      self.class.from_json(Api.private(:post, "/usd/deposits/#{id}/cancel"), self)
    end

    def self.all
      Api.private(:get, '/usd/deposits').map { |d| from_json(d) }
    end

    def self.deposit_methods
      { 1 => :astropay, 2 => :other }
    end

    def self.statuses
      { 1 => :pending, 2 => :done, 3 => :cancelled }
    end

    def self.reasons
      { 0 => :not_cancelled, 1 => :did_not_credit, 2 => :sender_unknown, 3 => :other, 4 => :user_cancelled }
    end
  end
end
