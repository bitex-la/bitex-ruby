require 'spec_helper'

describe Bitex::SpecieWithdrawal do
  before :each do
    Bitex.api_key = 'valid_api_key'
  end

  let(:as_json) do
    [
      6,             #  0 - API class reference
      12_345_678,    #  1 - id
      946_685_400,   #  2 - created_at
      1,             #  3 - specie { 0 => :btc }
      100.0,         #  4 - quantity
      1,             #  5 - status { 1 => :received, 2 => :pending, 3 => :done, 4 => :cancelled }
      0,             #  6 - reason { 0 => :not_cancelled, 1 => :insufficient_funds, 2 => :destination_invalid }
      '1helloworld', #  7 - to_address
      'label',       #  8 - label
      1,             #  9 - kyc_profile_id
      'ABC1'         # 10 - transaction_id
    ]
  end

  it_behaves_like 'API class'
  it_behaves_like 'API class with a specie'

  it 'sets quantity as BigDecimal' do
    thing = Bitex::SpecieWithdrawal.from_json(as_json).quantity
    thing.should be_a BigDecimal
    thing.should == 100.0
  end

  Bitex::SpecieWithdrawal.statuses.each do |code, symbol|
    it "sets status #{code} to #{symbol}" do
      as_json[5] = code
      Bitex::SpecieWithdrawal.from_json(as_json).status.should == symbol
    end
  end

  Bitex::SpecieWithdrawal.reasons.each do |code, symbol|
    it "sets reason #{code} to #{symbol}" do
      as_json[6] = code
      Bitex::SpecieWithdrawal.from_json(as_json).reason.should == symbol
    end
  end

  it 'sets label' do
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
    stub_private(:post, '/private/btc/withdrawals', 'specie_withdrawal', address: '1ADDR', amount: 110, label: 'thelabel')
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
