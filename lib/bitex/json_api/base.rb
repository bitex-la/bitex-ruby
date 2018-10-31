module Bitex
  module JsonApi
    # Generic base resource for Bitex resources.
    class Base < JsonApiClient::Resource
      extend Forwardable

      self.site = 'https://dev.bitex.la:3000/api/'

      def self.private_request
        with_headers(Authorization: Bitex.api_key) { yield }
      end
      def_delegator self, :private_request
    end
  end
end
