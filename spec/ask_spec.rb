require 'spec_helper'

describe Bitex::Ask do
  let(:as_json) do
    [
      1,         #  0 - API class reference
      12345678,  #  1 - id
      946685400, #  2 - created_at
      1,         #  3 - order_book
      100.0,     #  4 - quantity
      100.0,     #  5 - remaining_quantity
      1000.0,    #  6 - price
      1,         #  7 - status
      0,         #  8 - reason
      10.0,      #  9 - produced_amount
      'User#1'   # 10 - issuer
    ]
  end

  it_behaves_like 'API class'
  it_behaves_like 'API class with a order_book'
  it_behaves_like 'JSON deserializable order'

  describe 'Api calls' do
    before(:each) { Bitex.api_key = 'valid_api_key' }
    it_behaves_like 'Order', 'asks'
  end

  { quantity: 100.0, remaining_quantity: 100.0, produced_amount: 10.0 }.each do |field, value|
    it "sets #{field} as BigDecimal" do
      thing = subject.class.from_json(as_json).send(field)
      thing.should be_a BigDecimal
      thing.should == value
    end
  end
end
