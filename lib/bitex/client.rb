module Bitex
  # This client connects via API to Bitex resources.
  class Client
    attr_reader :api_key

    def initialize(api_key: nil, sandbox: false)
      @api_key = api_key
      setup_environment(sandbox)
    end

    def setup_environment(sandbox)
      Base.site = "https://#{'sandbox.' if sandbox}bitex.la/api/"
    end

    def asks
      @asks ||= Forwarder.new(Ask, api_key)
    end
  end
end
