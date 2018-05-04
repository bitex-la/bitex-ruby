module Bitex
  class Payment
    attr_accessor :id, :user_id, :amount, :currency_id, :expected_quantity,
      :previous_expected_quantity, :confirmed_quantity, :unconfirmed_quantity,
      :valid_until, :quote_valid_until, :last_quoted_on, :status, :address,
      :settlement_currency_id, :settlement_amount, :keep, :merchant_reference,
      :customer_reference

    # @visibility private
    def self.from_json(json)
      new.tap do |thing|
        json.each do |key,raw_value|
          next if raw_value.nil?

          value = if [:valid_until, :quote_valid_until, :last_quoted_on].include?(key.to_sym)
            Time.at(raw_value)
          else
            raw_value
          end
          thing.send("#{key}=", value) rescue nil
        end
      end
    end

    def self.create!(params)
      from_json(Api.private(:post, "/private/payments", params))
    end

    def self.find(id)
      from_json(Api.private(:get, "/private/payments/#{id}"))
    end

    def self.all
      Api.private(:get, "/private/payments").collect{|x| from_json(x) }
    end

    # Validate a callback and parse the given payment from it.
    # Returns nil if the callback was invalid.
    def self.from_callback(callback_params)
      from_json(callback_params["payment"]) if callback_params["api_key"] == Bitex.api_key
    end

    # Sets up the web-pos
    def self.pos_setup!(params)
      Api.private(:post, "/private/payments/pos_setup", params)
    end
  end
end
