require 'spec_helper'

describe Bitex::Bid do
  let(:as_json) do
    [1,12345678,946685400,1,100.00000000,100.00000000,1000.00000000,1]
  end
  
  it_behaves_like 'API class'
  it_behaves_like 'API class with a specie'
  it_behaves_like 'JSON deserializable order'

  describe 'Api calls' do
    before(:each){ Bitex.api_key = 'valid_api_key' }
    it_behaves_like 'Order', 'bids'
  end

  { amount: 100.0, remaining_amount: 100.0}.each do |field, value|
    it "sets #{field} as BigDecimal" do
      thing = subject.class.from_json(as_json).send(field)
      thing.should be_a BigDecimal
      thing.should == value
    end
  end
end
