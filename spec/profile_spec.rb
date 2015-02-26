require 'spec_helper'

describe Bitex::Profile do
  before(:each){ Bitex.api_key = 'valid_api_key' }

  it 'gets your profile' do
    stub_private(:get, '/private/profile', 'profile')
    Bitex::Profile.get.should == {
      usd_balance: 10000.0,
      usd_reserved: 2000.0,
      usd_available: 8000.0,
      btc_balance: 20.0,
      btc_reserved: 5.0,
      btc_available: 15.0,
      fee: 0.5,
      btc_deposit_address: "1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    }
  end
end
