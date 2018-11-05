module Bitex
  module JsonApi
    # Generic base resource for Bitex resources.
    class Base < JsonApiClient::Resource
      extend Forwardable

      self.site = 'https://dev.bitex.la:3000/api/'

      def self.private_request(otp: nil)
        with_headers(headers(otp)) { yield }
      end
      def_delegator self, :private_request

      def self.find(*args)
        super(*args)[0]
      end

      def self.headers(otp = nil)
        { Authorization: Bitex.api_key }.tap do |headers|
          headers.merge!(version: VERSION, 'One-Time-Password' => otp) if otp.present?
        end
      end

      private_class_method :headers
    end
  end
end
