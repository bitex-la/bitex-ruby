module Bitex
  # A withdrawal of some specie from your bitex.la balance
  class SpecieWithdrawal
    # @!attribute id
    #   @return [Integer] This SpecieWithdrawal's unique ID.
    attr_accessor :id

    # @!attribute created_at
    #   @return [Time] Time when this withdrawal was requested by you.
    attr_accessor :created_at

    # @!attribute specie
    #   @return [Symbol] :btc
    attr_accessor :specie

    # @!attribute quantity
    #   @return [BigDecimal] Quantity deposited
    attr_accessor :quantity

    # @!attribute status
    #  Returns the status of this withdrawal.
    #  * :received Our engine is checking if you have enough funds.
    #  * :pending your withdrawal was accepted and is being processed.
    #  * :done your withdrawal was processed and published to the network.
    #  * :cancelled your withdrawal could not be processed.
    attr_accessor :status

    # @!attribute reason
    #  Returns the reason for cancellation of this withdrawal, if any.
    #  * :not_cancelled
    #  * :insufficient_funds The instruction was received, but you didn't have
    #    enough funds available
    #  * :destination_invalid The destination address was invalid.
    attr_accessor :reason

    # @!attribute to_address
    #   @return [String] Address to wich you made this withdrawal.
    attr_accessor :to_address

    # @!attribute label
    #   @return [String] A custom label you gave to this address.
    attr_accessor :label

    # @!attribute kyc_profile_id
    #   @return [Integer] Kyc profile id for which this request was made.
    attr_accessor :kyc_profile_id

    # @!attribute transaction_id
    #   @return [String] Network transaction id, if available.
    attr_accessor :transaction_id

    # @visibility private
    # rubocop:disable Metrics/AbcSize
    def self.from_json(json)
      Api.from_json(new, json) do |thing|
        thing.specie = { 1 => :btc }[json[3]]
        thing.quantity = (json[4].presence || 0).to_d
        thing.status = statuses[json[5]]
        thing.reason = reasons[json[6]]
        thing.to_address = json[7]
        thing.label = json[8]
        thing.kyc_profile_id = json[9]
        thing.transaction_id = json[10]
      end
    end
    # rubocop:enable Metrics/AbcSize

    def self.create!(specie, address, amount, label, kyc_profile_id = nil)
      from_json(
        Api.private(
          :post,
          "/private/#{specie}/withdrawals",
          address: address,
          amount: amount,
          label: label,
          kyc_profile_id: kyc_profile_id
        )
      )
    end

    def self.find(specie, id)
      from_json(Api.private(:get, "/private/#{specie}/withdrawals/#{id}"))
    end

    def self.all(specie)
      Api.private(:get, "/private/#{specie}/withdrawals").map { |sw| from_json(sw) }
    end

    def self.statuses
      { 1 => :received, 2 => :pending, 3 => :done, 4 => :cancelled }
    end

    def self.reasons
      { 0 => :not_cancelled, 1 => :insufficient_funds, 2 => :destination_invalid }
    end
  end
end
