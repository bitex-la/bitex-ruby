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

    # @visibility private
    def self.from_json(json)
      status_lookup = {
        1 => :received,
        2 => :pending,
        3 => :done,
        4 => :cancelled,
      }
      reason_lookup = {
        0 => :not_cancelled,
        1 => :insufficient_funds,
        2 => :no_instructions,
        3 => :recipient_unknown,
      }
      Api.from_json(new, json) do |thing|
        thing.amount = BigDecimal.new(json[3].to_s)
        thing.status = status_lookup[json[4]]
        thing.reason = reason_lookup[json[5]]
      end
    end
  end
end
