require 'spec_helper'

describe Bitex::Buy do
  let(:as_json) do
    [4,12345678,946685400,1,100.50000000,201.0000000,0.05000000,2.00000000,456]
  end
  
  it_behaves_like 'API class'
  it_behaves_like 'API class with a specie'
  it_behaves_like 'JSON deserializable match'

  it "sets the bid id" do
    thing = subject.class.from_json(as_json).bid_id
    thing.should == 456
  end
end
