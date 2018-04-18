require 'spec_helper'

describe Bitex::SpecieDeposit do
  before :each do
    Bitex.api_key = 'valid_api_key'
  end

  let(:as_json) do
    # TODO: porque con tantos decimales en cero?
    [
      5,             # 0 - TODO: que seria?
      12_345_678,    # 1 - id
      946_685_400,   # 2 - created_at
      1,             # 3 - order_book
      100.50_000_000 # 4 - quantity
    ]
  end

  it_behaves_like 'API class'
  it_behaves_like 'API class with a order_book'

  it 'sets quantity as BigDecimal' do
    thing = Bitex::SpecieDeposit.from_json(as_json).quantity
    thing.should be_a BigDecimal
    thing.should == 100.5
  end

  it 'finds a single btc_usd deposit' do
    stub_private(:get, '/private/btc_usd/deposits/1', 'specie_deposit')
    deposit = Bitex::SpecieDeposit.find(:btc_usd, 1)
    deposit.should be_a Bitex::SpecieDeposit
    deposit.order_book.should == :btc_usd
  end

  it 'lists all btc_usd deposits' do
    stub_private(:get, '/private/btc_usd/deposits', 'specie_deposits')
    deposits = Bitex::SpecieDeposit.all(:btc_usd)
    deposits.should be_an Array
    deposits.first.should be_an Bitex::SpecieDeposit
  end
end
