require 'spec_helper'

describe Bitex::Bid do
  let(:as_json) do
    [
      1,           #  0 - API class reference
      12_345_678,  #  1 - id
      946_685_400, #  2 - created_at
      1,           #  3 - orderbook
      100.0,       #  4 - quantity
      100.0,       #  5 - remaining_quantity
      1_000.0,     #  6 - price
      1,           #  7 - status
      0,           #  8 - reason
      10.0,        #  9 - produced_amount
      'User#1'     # 10 - issuer
    ]
  end

  it_behaves_like 'API class'
  it_behaves_like 'API class with a orderbook'
  it_behaves_like 'JSON deserializable order'

  describe 'Api calls' do
    before(:each) { Bitex.api_key = 'valid_api_key' }
    it_behaves_like 'Order', 'bids'
  end

  { amount: 100.0, remaining_amount: 100.0, produced_quantity: 10.0 }.each do |field, value|
    it "sets #{field} as BigDecimal" do
      thing = subject.class.from_json(as_json).send(field)
      thing.should be_a BigDecimal
      thing.should == value
    end
  end
end
