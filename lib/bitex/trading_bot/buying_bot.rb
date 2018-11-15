module Bitex
  class BuyingBot < TradingBot
    # GET /api/buying_bots
    #
    # Get all Buying Bots.
    #
    # @return [Array<BuyingBot>]
    # self.all

    # GET /api/buying_bot/:id
    #
    # @param [String|Integer] id.
    #
    # @return [BuyingBot]
    # self.find(id:)

    # POST /api/buying_bots
    #
    # A buying bot is an assistant that puts Buy orders for you. It uses a strategy of dividing the amount and making the
    # orders smaller, to get the best price.
    #
    # @param [Float|String] amount:
    #   The amount of quote money that you intend to spend buying base money.
    #   Both the quote and the base currencies are determined by the Orderbook selected.
    #   (e.g. A buying bot with amount = 100 and orderbook = BTC/USD, will spend 100 dollars in buying as much BTC as it can).
    #
    # @param [Integer|String] orderbook_id:
    #   To get all possible orderbook_codes check Orderbooks
    #
    # @return [BuyingBot]
    # self.create(amount:, orderbook_id:)

    # POST /api/buying_bots/:id/cancel
    #
    # This action represents an intention to cancel the Buying Bot.
    # No new bids will be made but if one is already being executed, it could be matched.
    #
    # @return [nil]
    # self.cancel!(id:)
  end
end
