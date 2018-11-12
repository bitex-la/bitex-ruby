module Bitex
  module JsonApi
    module KYC
      # pending doc TODO
      class ArgentinaInvoicingDetailSeed < Base
        def self.create(address:, country:, full_name:, receipt_kind_code:, tax_id:, tax_id_kind_code:, vat_status_code:)
          private_request do
            super(
              address: address,
              country: country,
              full_name: full_name,
              receipt_kind_code: receipt_kind_code,
              tax_id: tax_id,
              tax_id_kind_code: tax_id_kind_code,
              vat_status_code: vat_status_code
            )
          end
        end
      end
    end
  end
end
