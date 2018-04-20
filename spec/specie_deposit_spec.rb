require 'spec_helper'

describe Bitex::SpecieDeposit do
  before :each do
    Bitex.api_key = 'valid_api_key'
  end

  let(:as_json) do
    [
      5,          # 0 - API class reference
      12_345_678, # 1 - id
      9_466_854,  # 2 - created_at
      1,          # 3 - specie { 0 => :btc }
      100.5       # 4 - quantity
    ]
  end

  it_behaves_like 'API class'
  it_behaves_like 'API class with a specie'

  it 'sets quantity as BigDecimal' do
    thing = Bitex::SpecieDeposit.from_json(as_json).quantity
    thing.should be_a BigDecimal
    thing.should == 100.5
  end

  it 'finds a single btc deposit' do
    stub_private(:get, '/private/btc/deposits/1', 'specie_deposit')
    deposit = Bitex::SpecieDeposit.find(:btc, 1)
    deposit.should be_a Bitex::SpecieDeposit
    deposit.specie.should == :btc
  end

  it 'lists all btc deposits' do
    stub_private(:get, '/private/btc/deposits', 'specie_deposits')
    deposits = Bitex::SpecieDeposit.all(:btc)
    deposits.should be_an Array
    deposits.first.should be_an Bitex::SpecieDeposit
  end
end
