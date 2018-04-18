require 'spec_helper'

describe Bitex::Order do
  before(:each) do
    Bitex.api_key = 'valid_api_key'
  end

  it 'gets all orders' do
    stub_private(:get, '/private/orders', 'orders')
    bid, ask, empty = Bitex::Order.all
    bid.should be_a Bitex::Bid
    ask.should be_a Bitex::Ask
    empty.should be_nil
  end
end
