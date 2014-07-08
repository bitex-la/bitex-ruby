require 'spec_helper'

describe Bitex::Sell do
  let(:as_json) do
    [3,12345678,946685400,1,100.50000000,201.0000000,0.05000000,2.00000000,123]
  end
  
  it_behaves_like 'API class'
  it_behaves_like 'API class with a specie'
  it_behaves_like 'JSON deserializable match'

  it "sets the ask id" do
    thing = subject.class.from_json(as_json).ask_id
    thing.should == 123
  end
end
