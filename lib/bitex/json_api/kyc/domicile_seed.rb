module Bitex
  module JsonApi
    module KYC
      # pending doc TODO
      class DomicileSeed < Base
        def self.create(city:, country:, floor:, postal_code:, street_address:, street_number:, state:, apartment:)
          private_request do
            super(
              city: city,
              country: country,
              floor: floor,
              postal_code: postal_code,
              street_address: street_address,
              street_number: street_number,
              state: state,
              apartment: apartment
            )
          end
        end
      end
    end
  end
end
