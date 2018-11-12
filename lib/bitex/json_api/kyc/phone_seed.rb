module Bitex
  module JsonApi
    module KYC
      # pending doc TODO
      class PhoneSeed < Base
        def self.create(country:, number:, phone_kind_code:, has_telegram:, has_whatsapp:, note:)
          private_request do
            super(
              country: country,
              number: number,
              phone_kind_code: phone_kind_code,
              has_telegram: has_telegram,
              has_whatsapp: has_whatsapp,
              note: note
            )
          end
        end
      end
    end
  end
end
