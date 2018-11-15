module Bitex
  # User's addresses to deposit any crypto currency.
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
      where(user_id: 'me').all
    end

    # GET /api/users/me/asset_wallets/:id
    #
    # Get Asset Wallets.
    #
    # @return [AssetWallet]
    def self.find(id:)
      where(user_id: 'me').find(id)[0]
    end
  end
end
