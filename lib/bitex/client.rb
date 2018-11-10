module Bitex
  # This client connects via API to Bitex resources.
  class Client
    attr_accessor :api_key, :sandbox, :debug, :ssl_version

    def initialize(api_key: nil, sandbox: false, debug: false, ssl_version: nil)
      @api_key = api_key
      @sandbox = sandbox
      @debug = debug
      @ssl_version = ssl_version
    end

    def accounts
      with_client { JsonApi::Account }
    end

    def api_keys
      with_client { JsonApi::ApiKey }
    end

    def asset_wallets
      with_client { JsonApi::AssetWallet }
    end

    def asks
      with_client { JsonApi::Ask }
    end

    def bids
      with_client { JsonApi::Bid }
    end

    def buying_bots
      with_client { JsonApi::BuyingBot }
    end

    def cash_withdrawals
      with_client { JsonApi::CashWithdrawal }
    end

    def coin_withdrawals
      with_client { JsonApi::CoinWithdrawal }
    end

    def markets
      with_client { JsonApi::Market }
    end

    def movements
      with_client { JsonApi::Movement }
    end

    def orderbooks
      with_client { JsonApi::Orderbook }
    end

    def orders
      with_client { JsonApi::Order }
    end

    def payments
      with_client { JsonApi::Payment }
    end

    def pos
      with_client { JsonApi::Pos }
    end

    def selling_bots
      with_client { JsonApi::SellingBot }
    end

    def tickers
      with_client { JsonApi::Ticker }
    end

    def withdrawal_instructions
      with_client { JsonApi::WithdrawalInstruction }
    end

    def natural_docket_seeds
      with_client { JsonApi::KYC::NaturalDocketSeed }
    end

    def note_seeds
      with_client { JsonApi::KYC::NoteSeed }
    end

    def identification_seeds
      with_client { JsonApi::KYC::IdentificationSeed }
    end

    private

    def with_client
      Bitex.api_key = api_key
      Bitex.sandbox = sandbox
      Bitex.debug = debug
      Bitex.ssl_version = ssl_version
      yield
    end
  end

  class ClientError < StandardError
  end
end
