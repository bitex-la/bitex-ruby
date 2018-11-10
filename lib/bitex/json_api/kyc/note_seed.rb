module Bitex
  module JsonApi
    module KYC
      class NoteSeed < Base
        def self.create(title:, body:)
          private_request { super(title: title, body: body) }
        end
      end
    end
  end
end
