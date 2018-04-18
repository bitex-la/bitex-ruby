require 'spec_helper'

describe Bitex::SpecieDeposit do
  before :each do
    Bitex.api_key = 'valid_api_key'
  end

  let(:as_json) do
    [5,12345678,946685400,1,100.50000000]
  end

  it_behaves_like 'API class'
  it_behaves_like 'API class with a orderbook'

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
