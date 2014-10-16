module Bitex
  # Exchange rates for cash in and cash out
  class Rates
    # The rates tree conveniently formatted as a ruby Hash with
    # symbolized keys.
    # @see https://bitex.la/developers#rates
    def self.all
      Api.private(:get, "/private/rates").deep_symbolize_keys
    end
  end
end
