require 'spec_helper'

describe Bitex::SpecieDeposit do
  let(:as_json) do
    [5,12345678,946685400,1,100.50000000]
  end

  it_behaves_like 'API class'
  it_behaves_like 'API class with a specie'

  it "sets quantity as BigDecimal" do
    thing = Bitex::SpecieDeposit.from_json(as_json).quantity
    thing.should be_a BigDecimal
    thing.should == 100.5
  end
end
