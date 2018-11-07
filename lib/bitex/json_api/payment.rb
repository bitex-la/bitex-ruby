module Bitex
  module JsonApi
    # Our Merchants API lets you accept bitcoin without worrying about the inner workings of the bitcoin Price and the bitcoin
    # Network.
    #
    # You just tell us the amount to charge in the customer's currency and we'll quote the bitcoin equivalent and set up a unique
    # Bitcoin Address for the bitcoin to be sent to. Each payment corresponds to a different bitcoin address.
    #
    # You can send bitcoin addresses via email, show them in your checkout using your own UI libraries, or easier yet: You can
    # setup your own Bitex powered point of sale and use the user friendly Payment's Page.
    #
    # All Bitcoins received as payment will be sold automatically at the best BTC/USD market price in Bitex. You can optionally
    # decide to keep part of the received Bitcoin and withdraw or sell them at a later date.
    #
    # Both USD and/or BTC received as payment will be credited to your Bitex Balance and can be withdrawn as per our supported
    # cash-out methods.
    #
    # Payments which are too small for our orderbook (roughly 2 USD or less) will not be settled automatically. They will be kept
    # as bitcoin in your balance and it's up to you to decide when to sell them.
    #
    # Contact us if you need settlements in currencies other than BTC or USD; if you need to have a guaranteed price instead of
    # settling at the best BTC/USD price; or if you need to automatically settle lots of micro-payments.
    class Payment < Base
      has_many :bitcoin_addresses

      def self.table_name
        'merchants/payments'
      end

      def self.type
        'payments'
      end

      # GET /api/merchant/payments
      #
      # Get all our paymets
      #
      # @return [ResulSet<Payment>]
      def self.all
        private_request { super }
      end

      # GET /api/merchant/payments/:id
      #
      # Get Payment.
      #
      # @param [String|Integer] id: payment id.
      #
      # @return [Payment]
      def self.find(id:)
        private_request { super(id) }
      end

      # POST /api/merchants/payments
      #
      # Send us an amount and currency, and we'll quote it in bitcoin and give you an address where the payment is expected.
      # The bitcoins will credit to your Bitex account and can be sold automatically to get the original amount in your requested
      # currency.
      #
      # Payments have an expiration of 1 hour, the bitcoin transaction must be initiated within that timeframe, if your customer
      # takes longer you can always create a new payment and get a new quote and bitcoin address. If someone pays to an address
      # after the payment is expired the bitcoin quantity will still be credited to your bitex.la, so it's possible for you to
      # issue a refund and/or forward the received bitcoin to a new payment address yourself.
      #
      # At the moment, the payments are only accepted in BTC and are transferred to the merchant in USD (unless he keeps 100% in
      # BTC), no matter the amount or the currency specified in the payment.
      #
      # @param [String|Float] amount: Amount that the customer should pay.
      # @param [Integer] currency: Id of the Payment currency. Possible options are:
      #   [:btc, :usd, :ars, :uyu, :eur, :clp, :pen, :brl, :cop, :mxn, :pyg, :cny, :inr, :bch]
      # @param [String|Float] keep: Percentage of the received money to keep in BTC instead of converting it to USD.
      # @param [String] callback_url: You can provide a callback_url to get notifications about a payment. When a callback_url is
      #   set for a payment Bitex will POST updates to it everytime a payment status changes.Your callback_url must be HTTPS
      #   because we want to make sure we're only contacting you, and it will include your first active API key in it, so that
      #   you know it's us sending the callback. Your API key is our shared secret, so you may want to handle it the same way you
      #   handle your users login credentials, hiding it from web server request logs for example. Our request's content type
      #   will be application/json and the content will be a structure containing your API key and the payment as it would be
      #   returned when querying its status.
      def self.create(amount:, currency_code:, keep:, callback_url:, customer_reference:, merchant_reference:)
        raise CurrencyError unless valid_currency?(currency_code)

        private_request do
          super(
            amount: amount,
            currency: currency_id(currency_code),
            keep: keep,
            callback_url: callback_url,
            customer_reference: customer_reference,
            merchant_reference: merchant_reference
          )
        end
      end

      # @param [String] code. Values: [:btc, :usd, :ars, :uyu, :eur, :clp, :pen, :brl, :cop, :mxn, :pyg, :cny, :inr, :bch]
      #
      # @return [true] if currency code is valid.
      def self.valid_currency?(code)
        currencies.include?(code)
      end

      # @param [Symbol] code.
      #
      # @return [Integer] currency id.
      def self.currency_id(code)
        currencies[code]
      end

      # @return [Hash] code and id currencies.
      def self.currencies
        { btc: 1, usd: 3, ars: 4, uyu: 5, eur: 6, clp: 7, pen: 8, brl: 9, cop: 10, mxn: 11, pyg: 12, cny: 13, inr: 14, bch: 16 }
      end

      private_class_method :valid_currency?, :currency_id, :currencies
    end
  end
end
