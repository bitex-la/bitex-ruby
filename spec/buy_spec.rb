require 'spec_helper'

describe Bitex::Buy do
  let(:as_json) do
    [
      4,           #  0 - API class reference
      12_345_678,  #  1 - id
      946_685_400, #  2 - created_at
      1,           #  3 - order_book
      100.5,       #  4 - quantity
      201,         #  5 - amount
      0.05,        #  6 - fee
      2,           #  7 - price
      456          #  8 - bid_id
    ]
  end

  it_behaves_like 'API class'
  it_behaves_like 'API class with a order book'
  it_behaves_like 'JSON deserializable match'

  it 'sets the bid id' do
    thing = subject.class.from_json(as_json).bid_id
    thing.should == 456
  end
end
