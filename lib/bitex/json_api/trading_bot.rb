module Bitex
  module JsonApi
    # Trading Bots can manage a crypto sale or buy to help you get a better pricing than you would get if you executed the full
    # amount in a single order.
    #
    # The strategy used by bots is rather simple: They split up the amount to buy or sell in chunks of a given size and place
    # orders at the best market price.
    #
    # Orders are spaced by time_to_live seconds to allow for new buyers and sellers to replenish the orderbook before executing
    # again. Orders will be cancelled after time_to_live seconds if still executing.
    #
    # Bots also make sure to prevent executing in low-liquidity conditions: they will not place new orders if the spread
    # between the best Bid and the best Ask is over 10 USD.
    #
    # Bots do not check or lock funds! If your robot fails to place an order because of insufficient funds or other, then it will
    # be terminated prematurely. You'll find the termination reason in exit_status.
    class TradingBot < Base
      has_one :orderbook

      # GET /api/:trading_bots
      #
      # @return [Array<TradingBot>]
      def self.all
        private_request { super }
      end

      # GET /api/:trading_bots/:id
      #
      # @param [String|Integer] id.
      #
      # @return [TradingBot]
      def self.find(id:)
        private_request { super(id) }
      end

      # POST /api/:trading_bots
      #
      # @return [TradingBot]
      def self.create(amount:, orderbook_id:)
        raise UnknownOrderbook unless valid_orderbook?(orderbook_id)

        new(amount: 100)
          .tap { |bot| bot.relationships.orderbook = Orderbook.new(id: orderbook_id) }
          .tap { |bot| private_request { bot.save  } }
      end

      custom_endpoint :cancel, on: :collection, request_method: :post
      # POST /api/:trading_bots/:id/cancel
      #
      # This action represents an intention to cancel the Trading Bot.
      # No new orders will be made but if one is already being executed, it could be matched.
      #
      # @param [Symbol] orderbook_code. Values: Bitex::ORDERBOOKS.keys
      # @param [Integer] id.
      #
      # @return [nil]
      def self.cancel!(id:)
        private_request { cancel(id: id)[0] }
      end

      # @param [Integer|String] orderbook_id: { 1 => :btc_usd, 5 => :btc_ars, 11 => :btc_clp, 10 => :btc_pyg, 12 => :btc_uyu }
      #
      # @return [true] if orderbook id is valid.
      def self.valid_orderbook?(id)
        ORDERBOOKS.values.include?(id.to_i)
      end

      private_class_method :valid_orderbook?
    end
  end
end