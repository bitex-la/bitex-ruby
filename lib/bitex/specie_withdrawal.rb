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
    #   @return [Symbol] :btc or :ltc
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
        2 => :destination_invalid,
      }
      Api.from_json(new, json, true) do |thing|
        thing.quantity = BigDecimal.new(json[4].to_s)
        thing.status = status_lookup[json[5]]
        thing.reason = reason_lookup[json[6]]
        thing.to_address = json[7]
        thing.label = json[8]
        thing.kyc_profile_id = json[9]
      end
    end

    def self.create!(specie, address, amount, label, kyc_profile_id=nil)
      from_json(Api.private(:post, "/private/#{specie}/withdrawals", {
        address: address,
        amount: amount,
        label: label,
        kyc_profile_id: kyc_profile_id
      }))
    end

    def self.find(specie, id)
      from_json(Api.private(:get, "/private/#{specie}/withdrawals/#{id}"))
    end

    def self.all(specie)
      Api.private(:get, "/private/#{specie}/withdrawals")
        .collect{|x| from_json(x) }
    end
  end
end
