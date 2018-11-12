module Bitex
  module JsonApi
    module KYC
      class Issue < Base
        custom_endpoint :current, on: :collection, request_method: :get

        def self.current!
          private_request { current[0] }
        end
      end
    end
  end
end
