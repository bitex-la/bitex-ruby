module Bitex
  module JsonApi
    # Request type for calls that do not need authentication.
    class PublicRequest < Faraday::Middleware
      def call(env)
        env[:request_headers]['Content-Type'] = 'application/vnd.api+json'
        env[:request_headers]['Accept'] = 'application/vnd.api+json'
        @app.call(env)
      end
    end

    # Request type for calls that need authentication.
    class PrivateRequest < PublicRequest
      def call(env)
        env[:request_headers]['Authorization'] = 'tu vieja'
        super(env)
      end
    end
  end
end
