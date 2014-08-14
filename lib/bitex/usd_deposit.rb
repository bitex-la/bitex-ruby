module Bitex
  # A deposit of USD to your bitex.la balance.
  class UsdDeposit
    # @!attribute id
    #   @return [Integer] This UsdDeposit's unique ID.
    attr_accessor :id

    # @!attribute created_at
    #   @return [Time] Time when this deposit was announced by you.
    attr_accessor :created_at

    # @!attribute requested_amount
    #   @return [BigDecimal] For pre-announced deposits, this is the amount you
    #     requested to deposit.
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
    #  * :pending your deposit notice was received, we're waiting for the funds
    #    to credit.
    #  * :done your deposit credited correctly, the funds are available in your
    #    balance.
    #  * :cancelled your deposit did not credit, check the 'reason' field.
    attr_accessor :status

    # @!attribute reason
    #  The reason for cancellation of this deposit, if any.
    #  * :not_cancelled.
    #  * :did_not_credit funds never arrived to our end.
    #  * :sender_unknown we could not accept these funds because you're not the
    #    sender.
    #  * :other we'll contact you regarding this deposit.
    attr_accessor :reason

    # @visibility private
    def self.from_json(json)
      deposit_method_lookup = {
        1 => :astropay,
        2 => :other,
      }
      status_lookup = {
        1 => :pending,
        2 => :done,
        3 => :cancelled,
      }
      reason_lookup = {
        0 => :not_cancelled,
        1 => :did_not_credit,
        2 => :sender_unknown,
        3 => :other,
      }
      Api.from_json(new, json) do |thing|
        thing.requested_amount = BigDecimal.new(json[3].to_s)
        thing.amount = BigDecimal.new(json[4].to_s)
        thing.deposit_method = deposit_method_lookup[json[5]]
        thing.status = status_lookup[json[6]]
        thing.reason = reason_lookup[json[7]]
      end
    end
  end
end
