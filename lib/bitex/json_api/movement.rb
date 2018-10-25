module Bitex
  module JsonApi
    class Movement < Base
      # GET /api/movements/
      # self.all
      def self.all
        private_request { super() }
      end
    end
  end
end
