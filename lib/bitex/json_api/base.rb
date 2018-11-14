module Bitex
  module JsonApi
    # Generic base resource for Bitex resources.
    class Base < JsonApiClient::Resource
      def self.find(*args)
        super(*args)[0]
      end
    end
  end
end
