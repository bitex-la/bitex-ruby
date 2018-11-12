module Bitex
  module JsonApi
    module KYC
      class ChileInvoicingDetailSeed < Base
        def self.create(ciudad:, comuna:, giro:, tax_id:, vat_status_code:)
          private_request { super(ciudad: ciudad, comuna: comuna, giro: giro, tax_id: tax_id, vat_status_code: vat_status_code) }
        end
      end
    end
  end
end
