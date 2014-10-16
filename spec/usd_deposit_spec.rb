require 'spec_helper'

describe Bitex::UsdDeposit do
  before :each do 
    Bitex.api_key = 'valid_api_key'
  end

  let(:as_json) do
    [ 7,12345678,946685400,110.0000000, 100.00000000,1,1,0,
      'UY', 'UYU', 1, 'bank of new york mellon',
      {"status" => "OK","link" => "https://astr.com"}, 'ABABABABA']
  end

  it_behaves_like 'API class'

  it "sets amount as BigDecimal" do
    thing = Bitex::UsdDeposit.from_json(as_json).amount
    thing.should be_a BigDecimal
    thing.should == 100.0
  end

  it "sets amount as BigDecimal" do
    thing = Bitex::UsdDeposit.from_json(as_json).requested_amount
    thing.should be_a BigDecimal
    thing.should == 110.0
  end
  
  it "sets country" do
    Bitex::UsdDeposit.from_json(as_json).country.should == 'UY'
  end
  
  it "sets currency" do
    Bitex::UsdDeposit.from_json(as_json).currency.should == 'UYU'
  end
  
  it "sets kyc profile" do
    Bitex::UsdDeposit.from_json(as_json).kyc_profile_id.should == 1
  end
  
  it "sets details" do
    Bitex::UsdDeposit.from_json(as_json).request_details.should ==
      'bank of new york mellon'
  end
  
  it "sets the astropay_response_body" do
    Bitex::UsdDeposit.from_json(as_json).astropay_response_body.should ==
      {"status" => "OK","link" => "https://astr.com"}
  end

  it "sets the third party reference" do
    Bitex::UsdDeposit.from_json(as_json).third_party_reference.should == 'ABABABABA'
  end

  { 1 => :astropay,
    2 => :other,
  }.each do |code, symbol|
    it "sets status #{code} to #{symbol}" do
      as_json[5] = code
      Bitex::UsdDeposit.from_json(as_json).deposit_method.should == symbol
    end
  end

  { 1 => :pending,
    2 => :done,
    3 => :cancelled,
  }.each do |code, symbol|
    it "sets status #{code} to #{symbol}" do
      as_json[6] = code
      Bitex::UsdDeposit.from_json(as_json).status.should == symbol
    end
  end

  { 0 => :not_cancelled,
    1 => :did_not_credit,
    2 => :sender_unknown,
    3 => :other,
  }.each do |code, symbol|
    it "sets reason #{code} to #{symbol}" do
      as_json[7] = code
      Bitex::UsdDeposit.from_json(as_json).reason.should == symbol
    end
  end
  
  it 'creates a new deposit' do
    stub_private(:post, "/private/usd/deposits", 'usd_deposit', {
      country: 'UY',
      amount: 110,
      currency: 'UYU',
      deposit_method: 'astropay',
      request_details: 'bank of new york mellon',
    })
    deposit = Bitex::UsdDeposit.create!('UY', 110, 'UYU', 'astropay',
      'bank of new york mellon') 
    deposit.should be_a Bitex::UsdDeposit
    deposit.astropay_response_body.should be_a Hash
    deposit.status.should == :pending
  end
  
  it 'finds a single usd deposit' do
    stub_private(:get, '/private/usd/deposits/1', 'usd_deposit')
    deposit = Bitex::UsdDeposit.find(1)
    deposit.should be_a Bitex::UsdDeposit
    deposit.status.should == :pending
  end
  
  it 'lists all usd deposits' do
    stub_private(:get, '/private/usd/deposits', 'usd_deposits')
    deposits = Bitex::UsdDeposit.all
    deposits.should be_an Array
    deposits.first.should be_an Bitex::UsdDeposit
    deposits.first.status.should == :pending
  end
end
