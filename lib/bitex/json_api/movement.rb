module Bitex
  module JsonApi
    # This displays your movements (Buy, Sell, Deposit & Withdraw) of the last 3 days.
    class Movement < Base
      # GET /api/movements/
      # self.all
      def self.all
        private_request { super() }
      end
    end
  end
end
