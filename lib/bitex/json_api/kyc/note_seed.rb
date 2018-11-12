module Bitex
  module JsonApi
    module KYC
      # pending doc TODO
      class NoteSeed < Base
        def self.create(title:, body:)
          private_request { super(title: title, body: body) }
        end
      end
    end
  end
end
