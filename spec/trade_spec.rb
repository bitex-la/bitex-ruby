require 'spec_helper'

describe Bitex::Trade do
  before(:each) { Bitex.api_key = 'valid_api_key' }

  it 'gets all trades' do
    stub_private(:get, '/private/trades', :trades)

    buy, sell, other = Bitex::Trade.all

    buy.should be_a Bitex::Buy
    sell.should be_a Bitex::Sell
    other.should be_nil
  end
end
