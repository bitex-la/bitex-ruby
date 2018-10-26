module Bitex
  module JsonApi
    class AssetWallet < Base
      belongs_to :user

      # GET /api/users/me/asset_wallets
      #
      # Get Asset Wallets.
      # This resource has the user's addresses to deposit any crypto currency.
      # It has several scopes for the different services we provide.
      #
      # @return [Array<AssetWallet>]
      def self.all
        private_request { where(user_id: 'me').all }
      end
    end
  end
end
