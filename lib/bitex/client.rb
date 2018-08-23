module Bitex
  class Client
    attr_accessor :api_key, :sandbox, :debug, :ssl_version

    def initiliaze(api_key:, sandbox: false, debug: false, ssl_version: nil)
      @api_key = api_key
      @sandbox = sandbox
      @debug = debug
      @ssl_version = ssl_version
    end

    def markets
      @markets ||= JsonApi::Market
    end
  end

  class ClientError < StandardError
  end
end

