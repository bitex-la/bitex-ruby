module Bitex
  module JsonApi
    # Abstract class for Bids and Asks.
    class OrderGroup < Base
      belongs_to :market

      # GET /api/markets/:orderbook_code/[asks|bids]/:id
      #
      # @param [Symbol] orderbook_code. Values: Bitex::ORDERBOOKS.keys
      # @param [String|Integer] id.
      #
      # @return [Ask|Bid]
      def self.find(orderbook_code:, id:)
        raise UnknownOrderbook unless valid_code?(orderbook_code)

        where(market_id: orderbook_code).find(id)[0]
      end

      # POST /api/markets/:orderbook_code/[asks|bids]
      #
      # @param [Symbol] orderbook_code. Values: Bitex::ORDERBOOKS.keys
      # @param [BigDecimal] amount.
      # @param [BigDecimal] price.
      #
      # @return [Ask|Bid]
      def self.create(orderbook_code:, amount:, price:, wait: true)
        raise UnknownOrderbook unless valid_code?(orderbook_code)
        raise InvalidArgument unless valid_amount?(amount)

        order = super(market_id: orderbook_code, amount: amount, price: price)
        raise OrderNotPlaced, order.errors.full_messages.join if order.errors.present?

        retries = 0
        while wait && order.status == :received
          sleep(0.2)
          order = find(orderbook_code: orderbook_code, id: order.id)
          retries += 1

          # Wait 15 minutes for the order to be processed.
          raise StandardError, "Timed out waiting for #{name} ##{order.id}" if retries > 5000
        end
      end

      custom_endpoint :cancel, on: :collection, request_method: :post
      # POST /api/markets/:orderbook_code/[asks|bids]/cancel
      #
      # This action represents an intention to cancel an [Ask|Bid].
      # Despite of this endpoint responding with a 204 status, the Ask may not have been cancelled if it was previously matched.
      # In order to check the status of the ask, you can query all your active orders with the /api/orders endpoint.
      #
      # @param [Symbol] orderbook_code. Values: Bitex::ORDERBOOKS.keys
      # @param [Integer] id.
      def self.cancel!(orderbook_code:, ids: [])
        raise UnknownOrderbook unless valid_code?(orderbook_code)

        private_request { cancel(market_id: :btc_usd, _json: json_api_body_parser(ids)) }
      end

      # @return [String] resource type name.
      def self.resource_type
        name.demodulize.underscore.pluralize
      end

      # @param [Symbol] orderbook_code. Values: :btc_usd, :btc_ars, :bch_usd, :btc_pyg, :btc_clp, :btc_uyu
      #
      # @return [true] if orderbook code is valid.
      def self.valid_code?(orderbook_code)
        ORDERBOOKS.include?(orderbook_code)
      end

      # @param [Float|Decimal] amount.
      #
      # @return [Boolean] if amount isn't zero or negative.
      def self.valid_amount?(amount)
        amount.positive?
      end

      # @param [Array<String|Integer>] ids.
      #
      # @return [Hash] as Json API list data.
      def self.json_api_body_parser(ids)
        ids.map { |id| to_json_api_body(id) }
      end

      # @param [String|Integer] id.
      #
      # @return [Hash] as Json API data structure.
      def self.to_json_api_body(id)
        { data: { type: resource_type, id: id } }
      end

      private_class_method :valid_code?, :valid_amount?, :cancel, :json_api_body_parser, :to_json_api_body
    end
  end
end
