module Bitex
  module JsonApi
    # Overview of current orderbooks resume.
    class Orderbook < Base
      # GET /api/orderbooks
      #
      # Get all orderbooks with your codes, base and quotes currencies.
      #
      # @return JsonApiClient::ResultSet. It has the server response.
      # self.all
    end
  end
end
