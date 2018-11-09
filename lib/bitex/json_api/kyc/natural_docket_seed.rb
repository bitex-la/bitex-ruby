module Bitex
  module JsonApi
    module KYC
      class NaturalDocketSeed < Base
        def self.create(first_name:, last_name:, nationality:, gender_code:, marital_status_code:, politically_exposed:, birth_date:, job_title:, job_description:, politically_exposed_reason:)
          private_request do
            super(
              first_name: first_name,
              last_name: last_name,
              nationality: nationality,
              gender_code: gender_code,
              marital_status_code: marital_status_code,
              politically_exposed: politically_exposed,
              birth_date: birth_date,
              job_title: 'job_title',
              job_description: 'job_description',
              politically_exposed_reason: 'politically_exposed_reason'
            )
          end
        end
      end
    end
  end
end
