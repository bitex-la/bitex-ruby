module Bitex
  # This client connects via API to Bitex resources.
  class Client
    attr_accessor :api_key, :sandbox, :debug, :ssl_version

    def initialize(api_key: nil, sandbox: false, debug: false, ssl_version: nil)
      @api_key = api_key
      @sandbox = sandbox
      @debug = debug
      @ssl_version = ssl_version
    end

    def accounts
      with_client { JsonApi::Account }
    end

    def markets
      with_client { JsonApi::Market }
    end

    def tickers
      with_client { JsonApi::Ticker }
    end

    def orderbooks
      with_client { JsonApi::Orderbook }
    end

    def api_keys
      with_client { JsonApi::ApiKey }
    end

    private

    def with_client
      Bitex.api_key = self.api_key
      Bitex.sandbox = self.sandbox
      Bitex.debug = self.debug
      Bitex.ssl_version = self.ssl_version
      yield
    end
  end

  class ClientError < StandardError
  end
end
