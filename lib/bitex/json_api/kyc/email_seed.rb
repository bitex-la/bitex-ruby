module Bitex
  module JsonApi
    module KYC
      # pending doc TODO
      class EmailSeed < Base
        def self.create(address:, email_kind_code:)
          private_request { super(address: address, email_kind_code: email_kind_code) }
        end
      end
    end
  end
end
