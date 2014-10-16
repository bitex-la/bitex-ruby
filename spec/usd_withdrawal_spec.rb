require 'spec_helper'

describe Bitex::UsdWithdrawal do
  before :each do 
    Bitex.api_key = 'valid_api_key'
  end

  let(:as_json) do
    [8,12345678,946685400,100.00000000,1,0,'UY','UYU', 'bb', 'billy bob', 1, 'las instrucciones']
  end

  it_behaves_like 'API class'

  it "sets amount as BigDecimal" do
    thing = Bitex::UsdWithdrawal.from_json(as_json).amount
    thing.should be_a BigDecimal
    thing.should == 100.0
  end

  it 'sets country' do
    thing = Bitex::UsdWithdrawal.from_json(as_json).country
    thing.should == 'UY'
  end

  it 'sets currency' do
    thing = Bitex::UsdWithdrawal.from_json(as_json).currency
    thing.should == 'UYU'
  end

  it 'sets payment method' do
    thing = Bitex::UsdWithdrawal.from_json(as_json).payment_method
    thing.should == 'bb'
  end

  it 'sets label' do
    thing = Bitex::UsdWithdrawal.from_json(as_json).label
    thing.should == 'billy bob'
  end

  it 'sets kyc profile id' do
    thing = Bitex::UsdWithdrawal.from_json(as_json).kyc_profile_id
    thing.should == 1
  end

  it 'sets instructions' do
    thing = Bitex::UsdWithdrawal.from_json(as_json).instructions
    thing.should == 'las instrucciones'
  end

  { 1 => :received,
    2 => :pending,
    3 => :done,
    4 => :cancelled,
  }.each do |code, symbol|
    it "sets status #{code} to #{symbol}" do
      as_json[4] = code
      Bitex::UsdWithdrawal.from_json(as_json).status.should == symbol
    end
  end

  { 0 => :not_cancelled,
    1 => :insufficient_funds,
    2 => :no_instructions,
    3 => :recipient_unknown,
  }.each do |code, symbol|
    it "sets reason #{code} to #{symbol}" do
      as_json[5] = code
      Bitex::UsdWithdrawal.from_json(as_json).reason.should == symbol
    end
  end

  it 'creates a new withdrawal' do
    stub_private(:post, "/private/usd/withdrawals", 'usd_withdrawal', {
      country: 'UY',
      amount: 110,
      currency: 'UYU',
      payment_method: 'bb',
      instructions: 'bank of new york mellon',
      label: 'a label',
    })
    deposit = Bitex::UsdWithdrawal.create!('UY', 110, 'UYU', 'bb',
      'bank of new york mellon', 'a label') 
    deposit.should be_a Bitex::UsdWithdrawal
    deposit.status.should == :received
  end
  
  it 'finds a single usd deposit' do
    stub_private(:get, '/private/usd/withdrawals/1', 'usd_withdrawal')
    deposit = Bitex::UsdWithdrawal.find(1)
    deposit.should be_a Bitex::UsdWithdrawal
    deposit.status.should == :received
  end
  
  it 'lists all usd deposits' do
    stub_private(:get, '/private/usd/withdrawals', 'usd_withdrawals')
    deposits = Bitex::UsdWithdrawal.all
    deposits.should be_an Array
    deposits.first.should be_an Bitex::UsdWithdrawal
    deposits.first.status.should == :received
  end
end
