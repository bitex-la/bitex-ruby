require 'spec_helper'

describe Bitex::UsdWithdrawal do
  let(:as_json) do
    [8,12345678,946685400,100.00000000,1,0,]
  end

  it_behaves_like 'API class'

  it "sets amount as BigDecimal" do
    thing = Bitex::UsdWithdrawal.from_json(as_json).amount
    thing.should be_a BigDecimal
    thing.should == 100.0
  end

  { 1 => :received,
    2 => :pending,
    3 => :done,
    4 => :cancelled,
  }.each do |code, symbol|
    it "sets status #{code} to #{symbol}" do
      as_json[4] = code
      Bitex::UsdWithdrawal.from_json(as_json).status.should == symbol
    end
  end

  { 0 => :not_cancelled,
    1 => :insufficient_funds,
    2 => :no_instructions,
    3 => :recipient_unknown,
  }.each do |code, symbol|
    it "sets reason #{code} to #{symbol}" do
      as_json[5] = code
      Bitex::UsdWithdrawal.from_json(as_json).reason.should == symbol
    end
  end
end
