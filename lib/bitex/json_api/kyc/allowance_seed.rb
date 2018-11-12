module Bitex
  module JsonApi
    module KYC
      # pending doc TODO
      class AllowanceSeed < Base
        def self.create(kind_code:)
          private_request { super(kind_code: kind_code) }
        end
      end
    end
  end
end
