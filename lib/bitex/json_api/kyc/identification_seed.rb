module Bitex
  module JsonApi
    module KYC
      class IdentificationSeed < Base
        def self.create(identification_kind_code:, number:, issuer:, public_registry_authority:, public_registry_book:, public_registry_extra_data:)
          private_request do
            super(
              identification_kind_code: identification_kind_code,
              number: number,
              issuer: issuer,
              public_registry_authority: public_registry_authority,
              public_registry_book: public_registry_book,
              public_registry_extra_data: public_registry_extra_data
            )
          end
        end
      end
    end
  end
end
