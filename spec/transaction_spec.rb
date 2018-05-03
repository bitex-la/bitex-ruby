require 'spec_helper'

describe Bitex::Transaction do
  before(:each) { Bitex.api_key = 'valid_api_key' }

  it 'gets account summary' do
    stub_private(:get, '/private/account_summary', :account_summary)

    buy, sell, specie_deposit, specie_withdrawal, usd_deposit, usd_withdrawal = Bitex::Transaction.all

    buy.should be_an Bitex::Bid
    sell.should be_an Bitex::Ask
    specie_deposit.should be_an Bitex::SpecieDeposit
    specie_withdrawal.should be_an Bitex::SpecieWithdrawal
    usd_deposit.should be_an Bitex::UsdDeposit
    usd_withdrawal.should be_an Bitex::UsdWithdrawal
  end
end
