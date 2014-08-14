require 'spec_helper'

describe Bitex::SpecieWithdrawal do
  let(:as_json) do
    [6,12345678,946685400,1,100.00000000,1,0, '1helloworld', 'label']
  end

  it_behaves_like 'API class'
  it_behaves_like 'API class with a specie'

  it "sets quantity as BigDecimal" do
    thing = Bitex::SpecieWithdrawal.from_json(as_json).quantity
    thing.should be_a BigDecimal
    thing.should == 100.0
  end

  { 1 => :received,
    2 => :pending,
    3 => :done,
    4 => :cancelled,
  }.each do |code, symbol|
    it "sets status #{code} to #{symbol}" do
      as_json[5] = code
      Bitex::SpecieWithdrawal.from_json(as_json).status.should == symbol
    end
  end

  { 0 => :not_cancelled,
    1 => :insufficient_funds,
    2 => :destination_invalid,
  }.each do |code, symbol|
    it "sets reason #{code} to #{symbol}" do
      as_json[6] = code
      Bitex::SpecieWithdrawal.from_json(as_json).reason.should == symbol
    end
  end

  it "sets label" do
    thing = Bitex::SpecieWithdrawal.from_json(as_json).label
    thing.should == 'label'
  end

  it "sets to_addresses" do
    thing = Bitex::SpecieWithdrawal.from_json(as_json).to_address
    thing.should == "1helloworld"
  end
end
