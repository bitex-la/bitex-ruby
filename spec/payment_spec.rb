require 'spec_helper'

describe Bitex::Payment do
  before :each do 
    Bitex.api_key = 'valid_api_key'
  end

  let(:params_for_create) do
    {
      currency_id: 3,
      amount: 1000,
      callback_url: "https://example.com/ipn",
      keep: 25.0,
      customer_reference: "An Alto latte, no sugar",
      merchant_reference: "invoice#1234",
    }
  end
  
  let(:as_json) do
    {
      id: 1,
      user_id:  1,
      amount: 100.00,
      currency_id:  1,
      expected_quantity:  0.02,
      previous_expected_quantity: 0.018,
      confirmed_quantity: 0.0,
      unconfirmed_quantity: 0.0,
      valid_until:  1430226201,
      quote_valid_until:  1430226201,
      last_quoted_on: 1430220201,
      status: "pending",
      address: { 
        "id": 4,
        "public_address": "1ABC...",
      },
      settlement_currency_id: 2,
      settlement_amount:  100,
      keep: 1.5,
      merchant_reference: "Invoice#1234",
      customer_reference: "Frappuchino",
    }
  end
  
  let(:callback_params) do
    { "api_key" => 'valid_api_key', "payment" => as_json}
  end

  {
    id: 1,
    user_id:  1,
    amount: 100.00,
    currency_id:  1,
    expected_quantity:  0.02,
    previous_expected_quantity: 0.018,
    confirmed_quantity: 0.0,
    unconfirmed_quantity: 0.0,
    valid_until:  Time.at(1430226201),
    quote_valid_until:  Time.at(1430226201),
    last_quoted_on: Time.at(1430220201),
    status: "pending",
    address: { 
      "id": 4,
      "public_address": "1ABC...",
    },
    settlement_currency_id: 2,
    settlement_amount:  100,
    keep: 1.5,
    merchant_reference: "Invoice#1234",
    customer_reference: "Frappuchino",
  }.each do |field, value|
    it "sets #{field}" do
      subject.class.from_json(as_json).send(field).should == value
    end
  end

  it 'creates a new payment' do
    stub_private(:post, "/private/payments", 'payment',
      params_for_create)
    Bitex::Payment.create!(params_for_create)
      .should be_a Bitex::Payment
  end
  
  it 'finds a single payment' do
    stub_private(:get, '/private/payments/1', 'payment')
    Bitex::Payment.find(1).should be_a Bitex::Payment
  end
  
  it 'lists all payments' do
    stub_private(:get, '/private/payments', 'payments')
    payments = Bitex::Payment.all
    payments.should be_an Array
    payments.first.should be_a Bitex::Payment
  end
  
  it 'accepts a callback' do
    Bitex::Payment
      .from_callback(callback_params)
      .should be_a Bitex::Payment
  end
  
  it 'raises exception if invalid api key' do
    Bitex::Payment
      .from_callback(callback_params.merge("api_key" => 'bogus'))
      .should be_nil
  end
  
  it 'configures store' do
    pos_params = {  
      "merchant_name" => "Tierra Buena",
      "merchant_slug" => "tierrabuena",
      "merchant_logo" => "https://t.co/logo.png",
      "merchant_keep" => 0,
    }
    stub_private(:post, "/private/payments/pos_setup", 'pos_setup', pos_params.dup)
    Bitex::Payment.pos_setup!(pos_params)
      .should == pos_params
  end
end
