module Bitex
  # This client connects via API to Bitex resources.
  class Client
    attr_accessor :api_key, :sandbox, :debug, :ssl_version

    def initialize(api_key:, sandbox: false, debug: false, ssl_version: nil)
      @api_key = api_key
      @sandbox = sandbox
      @debug = debug
      @ssl_version = ssl_version
    end

    def markets
      @markets ||= JsonApi::Market
    end

    def tickers
      @tickers ||= JsonApi::Ticker
    end

    def order_books
      @order_books ||= JsonApi::OrderBook
    end
  end

  class ClientError < StandardError
  end
end
