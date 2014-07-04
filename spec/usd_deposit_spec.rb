require 'spec_helper'

describe Bitex::UsdDeposit do
  let(:as_json) do
    [7,12345678,946685400,100.00000000,1,1,0]
  end

  it_behaves_like 'API class'

  it "sets amount as BigDecimal" do
    thing = Bitex::UsdDeposit.from_json(as_json).amount
    thing.should be_a BigDecimal
    thing.should == 100.0
  end

  { 1 => :astropay,
    2 => :other,
  }.each do |code, symbol|
    it "sets status #{code} to #{symbol}" do
      as_json[4] = code
      Bitex::UsdDeposit.from_json(as_json).deposit_method.should == symbol
    end
  end

  { 1 => :pending,
    2 => :done,
    3 => :cancelled,
  }.each do |code, symbol|
    it "sets status #{code} to #{symbol}" do
      as_json[5] = code
      Bitex::UsdDeposit.from_json(as_json).status.should == symbol
    end
  end

  { 0 => :not_cancelled,
    1 => :did_not_credit,
    2 => :sender_unknown,
    3 => :other,
  }.each do |code, symbol|
    it "sets reason #{code} to #{symbol}" do
      as_json[6] = code
      Bitex::UsdDeposit.from_json(as_json).reason.should == symbol
    end
  end
end
