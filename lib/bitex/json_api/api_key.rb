module Bitex
  module JsonApi
    # You authenticate to the Bitex API by provinding one of your API keys as a POST or GET parameter called api_key.
    # You can have several active API keys at once.
    # It's your responsibility to keep all your API keys safe.
    # Always use the https protocol when making your requests.
    # Revoke your API keys immediately if you think they're compromised.
    # You need to Log in or Sign Up in order to create API Keys and use our Private Trading API.
    class ApiKey < Base
      # POST /api/api_keys
      #
      # Create an Api Key.
      # This endpoint always requires an OTP. Users that don't have the 2FA enabled, will not be able to create Api Keys.
      #
      # @param [Boolean] write.
      # @param [String] otp_code.
      #
      # @return JsonApiClient::ResultSet. It has the server response data, and created api key parsed to json api.
      def self.create(write: false, otp_code: nil)
        raise MalformedOtpCode unless valid_otp_code?(otp_code)

        private_request { super(write: write, meta: { otp: otp_code }) }
      end

      # GET /api/api_keys
      #
      # Get all api keys.
      #
      # @return JsonApiClient::ResultSet. It has the server response data, and all  api key parsed to json api.
      def self.all
        private_request { super }
      end

      # DELETE /api/api_keys/:id
      #
      # Delete Api Key
      #
      # @param [Integer] id.
      #
      # TODO doc returns
      def self.destroy(id)
        private_request { super(id: id) }
      end

      def self.valid_otp_code?(otp_code)
        return false if otp_code.nil? || otp_code.blank?
        return false unless otp_code.try(:to_i).is_a?(Numeric)
      end
    end
  end
end
