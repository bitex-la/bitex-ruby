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
      # @param [Symbol] level: [:read, :write]
      # @param [String] otp: your One Time Password.
      #
      # @return [ApiKey]
      def self.create(level: :read, otp: nil)
        raise MalformedOtp unless valid_otp?(otp)
        raise InvalidArgument unless valid_level?(level)

        private_request(otp: otp) { super(write: key_levels[level]) }
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
      # @return [nil]
      def destroy
        private_request { super }
      end

      def self.valid_otp?(otp_code)
        otp_code.present? && otp_code.is_numeric?
      end

      def self.valid_level?(key_level)
        key_levels.include?(key_level)
      end

      def self.key_levels
        { read: false, write: true }
      end

      private_class_method :valid_otp?, :valid_level?, :key_levels
    end
  end
end
