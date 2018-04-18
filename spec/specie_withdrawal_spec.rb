require 'spec_helper'

describe Bitex::SpecieWithdrawal do
  before :each do
    Bitex.api_key = 'valid_api_key'
  end

  let(:as_json) do
    [6,12345678,946685400,1,100.00000000,1,0, '1helloworld', 'label', 1, 'ABC1']
  end

  it_behaves_like 'API class'
  it_behaves_like 'API class with a orderbook'

  it 'sets quantity as BigDecimal' do
    thing = Bitex::SpecieWithdrawal.from_json(as_json).quantity
    thing.should be_a BigDecimal
    thing.should == 100.0
  end

  { 1 => :received, 2 => :pending, 3 => :done, 4 => :cancelled }.each do |code, symbol|
    it "sets status #{code} to #{symbol}" do
      as_json[5] = code
      Bitex::SpecieWithdrawal.from_json(as_json).status.should == symbol
    end
  end

  { 0 => :not_cancelled, 1 => :insufficient_funds, 2 => :destination_invalid }.each do |code, symbol|
    it "sets reason #{code} to #{symbol}" do
      as_json[6] = code
      Bitex::SpecieWithdrawal.from_json(as_json).reason.should == symbol
    end
  end

  it 'sets labelr' do
    thing = Bitex::SpecieWithdrawal.from_json(as_json).label
    thing.should == 'label'
  end

  it 'sets to_address' do
    thing = Bitex::SpecieWithdrawal.from_json(as_json).to_address
    thing.should == '1helloworld'
  end

  it 'sets transaction id' do
    thing = Bitex::SpecieWithdrawal.from_json(as_json).transaction_id
    thing.should == 'ABC1'
  end

  it 'sets the kyc profile id' do
    Bitex::SpecieWithdrawal.from_json(as_json).kyc_profile_id.should == 1
  end

  it 'creates a new withdrawal' do
    stub_private(:post, '/private/btc/withdrawals', 'specie_withdrawal', {
      address: '1ADDR',
      amount: 110,
      label: 'thelabel'
    })
    withdrawal = Bitex::SpecieWithdrawal.create!(:btc, '1ADDR', 110, 'thelabel')
    withdrawal.should be_a Bitex::SpecieWithdrawal
    withdrawal.status.should == :received
  end

  it 'finds a single usd deposit' do
    stub_private(:get, '/private/btc/withdrawals/1', 'specie_withdrawal')
    deposit = Bitex::SpecieWithdrawal.find(:btc, 1)
    deposit.should be_a Bitex::SpecieWithdrawal
    deposit.status.should == :received
  end

  it 'lists all usd deposits' do
    stub_private(:get, '/private/btc/withdrawals', 'specie_withdrawals')
    deposits = Bitex::SpecieWithdrawal.all(:btc)
    deposits.should be_an Array
    deposits.first.should be_an Bitex::SpecieWithdrawal
    deposits.first.status.should == :received
  end
end
