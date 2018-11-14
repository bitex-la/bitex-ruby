module Bitex
  # This client connects via API to Bitex resources.
  class Client
    attr_reader :api_key

    def initialize(api_key: nil, sandbox: false)
      @api_key = api_key
      environment(sandbox)
    end

    def environment(sandbox)
      Base.site = "https://#{'sandbox.' if sandbox}bitex.la/api/"
    end

    def accounts
      @accounts ||= Forwarder.new(Account, api_key)
    end

    def markets
      @markets ||= Forwarder.new(Market)
    end

    def api_keys
      @api_keys ||= Forwarder.new(ApiKey, api_key)
    end

    def asset_wallets
      @asset_wallets ||= Forwarder.new(AssetWallet, api_key)
    end

    def asks
      @asks ||= Forwarder.new(Ask, api_key)
    end

    def bids
      @bids ||= Forwarder.new(Bid, api_key)
    end

    def buying_bots
      @buying_bots ||= Forwarder.new(BuyingBot, api_key)
    end

    def cash_withdrawals
      @cash_withdrawals ||= Forwarder.new(CashWithdrawal, api_key)
    end

    def coin_withdrawals
      @coin_withdrawals ||= Forwarder.new(CoinWithdrawal, api_key)
    end

    def movements
      @movements ||= Forwarder.new(Movement, api_key)
    end

    def orderbooks
      @orderbooks ||= Forwarder.new(Orderbook, api_key)
    end

    def orders
      @orders ||= Forwarder.new(Order, api_key)
    end

    def payments
      @payments ||= Forwarder.new(Payment, api_key)
    end

    def pos
      @pos ||= Forwarder.new(Pos, api_key)
    end

    def selling_bots
      @selling_bots ||= Forwarder.new(SellingBot, api_key)
    end

    def tickers
      @tickers ||= Forwarder.new(Ticker, api_key)
    end

    def withdrawal_instructions
      @withdrawal_instructions ||= Forwarder.new(WithdrawalInstruction, api_key)
    end

    def issues
      @issues ||= Forwarder.new(KYC::Issue, api_key)
    end

    def allowance_seeds
      @allowance_seeds ||= Forwarder.new(KYC::AllowanceSeed, api_key)
    end

    def argentina_invoicing_detail_seeds
      @argentina_invoicing_detail_seeds ||= Forwarder.new(KYC::ArgentinaInvoicingDetailSeed, api_key)
    end

    def chile_invoicing_detail_seeds
      @chile_invoicing_detail_seeds ||= Forwarder.new(KYC::ChileInvoicingDetailSeed, api_key)
    end

    def domicile_seeds
      @domicile_seeds ||= Forwarder.new(KYC::DomicileSeed, api_key)
    end

    def email_seeds
      @email_seeds ||= Forwarder.new(KYC::EmailSeed, api_key)
    end

    def natural_docket_seeds
      @natural_docket_seeds ||= Forwarder.new(KYC::NaturalDocketSeed, api_key)
    end

    def note_seeds
      @note_seeds ||= Forwarder.new(KYC::NoteSeed, api_key)
    end

    def identification_seeds
      @identification_seeds ||= Forwarder.new(KYC::IdentificationSeed, api_key)
    end

    def phone_seeds
      @phone_seeds ||= Forwarder.new(KYC::PhoneSeed, api_key)
    end
  end
end
