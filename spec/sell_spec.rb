require 'spec_helper'

describe Bitex::Sell do
  let(:as_json) do
    [
      3,          #  0 - API class reference
      12_345_678, #  1 - id
      946685400,  #  2 - created_at
      1,          #  3 - order_book
      100.5,      #  4 - quantity
      201,        #  5 - amount
      0.05,       #  6 - fee
      2,          #  7 - price
      123         #  8 - ask_id
    ]
  end

  it_behaves_like 'API class'
  it_behaves_like 'API class with a order book'
  it_behaves_like 'JSON deserializable match'

  it 'sets the ask id' do
    thing = subject.class.from_json(as_json).ask_id
    thing.should == 123
  end
end
