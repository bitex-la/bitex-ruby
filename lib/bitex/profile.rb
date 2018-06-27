module Bitex
  # Your balances, fee and deposit addresses
  class Profile
    # Your profile conveniently formatted as a ruby hash with symbolized keys.
    # @see https://bitex.la/developers#profile
    def self.get
      Api.private(:GET, '/profile').symbolize_keys
    end
  end
end
