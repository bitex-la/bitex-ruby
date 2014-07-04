require 'spec_helper'

describe Bitex::Transaction do
  before(:each) do
    Bitex.api_key = 'valid_api_key'
  end
  
  it 'gets all transactions' do
    stub_private(:get, "/private/transactions", 'user_transactions')
    buy, sell, specie_deposit, specie_withdrawal, usd_deposit, usd_withdrawal =
      Bitex::Transaction.all
    buy.should be_a Bitex::Buy
    sell.should be_a Bitex::Sell
    specie_deposit.should be_a Bitex::SpecieDeposit
    specie_withdrawal.should be_a Bitex::SpecieWithdrawal
    usd_deposit.should be_a Bitex::UsdDeposit
    usd_withdrawal.should be_a Bitex::UsdWithdrawal
  end
end
