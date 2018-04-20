require 'spec_helper'

describe Bitex::UsdDeposit do
  before :each do
    Bitex.api_key = 'valid_api_key'
  end

  let(:as_json) do
    [
      7,                                                  # 00 - API class id
      12_345_678,                                         # 01 - id
      946_685_400,                                        # 02 - created_at
      110.0,                                              # 03 - requested_amount
      100.0,                                              # 04 - amount
      1,                                                  # 05 - deposit_method
      1,                                                  # 06 - status
      0,                                                  # 07 - reason
      'UY',                                               # 08 - country
      'UYU',                                              # 09 - currency
      1,                                                  # 10 - kyc_profile_id
      'bank of new york mellon',                          # 11 - request_details
      { 'status' => 'OK', 'link' => 'https://astr.com' }, # 12 - astropay_response_body
      'REFERENCE'                                         # 13 - third_party_reference
    ]
  end

  it_behaves_like 'API class'

  it 'sets amount as BigDecimal' do
    deposit = Bitex::UsdDeposit.from_json(as_json).amount
    deposit.should be_a BigDecimal
    deposit.should be 100.0
  end

  it 'sets amount as BigDecimal' do
    deposit = Bitex::UsdDeposit.from_json(as_json).requested_amount

    deposit.should be_a BigDecimal
    deposit.should be 110.0
  end

  it 'sets country' do
    Bitex::UsdDeposit.from_json(as_json).country.should eq 'UY'
  end

  it 'sets currency' do
    Bitex::UsdDeposit.from_json(as_json).currency.should eq 'UYU'
  end

  it 'sets kyc profile' do
    Bitex::UsdDeposit.from_json(as_json).kyc_profile_id.should be 1
  end

  it 'sets details' do
    Bitex::UsdDeposit.from_json(as_json).request_details.should eq 'bank of new york mellon'
  end

  it 'sets the astropay_response_body' do
    Bitex::UsdDeposit.from_json(as_json).astropay_response_body.should eq('status' => 'OK', 'link' => 'https://astr.com')
  end

  it 'sets the third party reference' do
    Bitex::UsdDeposit.from_json(as_json).third_party_reference.should eq 'REFERENCE'
  end

  Bitex::UsdDeposit.deposit_methods.each do |code, deposit_method|
    it "sets deposit_method #{code} to #{deposit_method}" do
      as_json[5] = code
      Bitex::UsdDeposit.from_json(as_json).deposit_method.should be deposit_method
    end
  end

  Bitex::UsdDeposit.statuses.each do |code, status|
    it "sets status #{code} to #{status}" do
      as_json[6] = code
      Bitex::UsdDeposit.from_json(as_json).status.should be status
    end
  end

  Bitex::UsdDeposit.reasons.each do |code, reason|
    it "sets reason #{code} to #{reason}" do
      as_json[7] = code
      Bitex::UsdDeposit.from_json(as_json).reason.should be reason
    end
  end

  it 'creates a new deposit' do
    stub_private(
      :post,
      '/private/usd/deposits',
      :usd_deposit,
      country: 'UY',
      amount: 110,
      currency: 'UYU',
      deposit_method: :astropay,
      request_details: 'bank of new york mellon'
    )

    deposit = Bitex::UsdDeposit.create!('UY', 110, 'UYU', :astropay, 'bank of new york mellon')

    deposit.should be_a Bitex::UsdDeposit
    deposit.astropay_response_body.should be_a Hash
    deposit.status.should be :pending
  end

  it 'finds a single usd deposit' do
    id = 1
    stub_private(:get, "/private/usd/deposits/#{id}", :usd_deposit)

    deposit = Bitex::UsdDeposit.find(id)

    deposit.should be_a Bitex::UsdDeposit
    deposit.status.should be :pending
  end

  it 'cancels a deposit' do
    id = 12_345_678
    stub_private(:get, "/private/usd/deposits/#{id}", :usd_deposit)
    stub_private(:post, "/private/usd/deposits/#{id}/cancel", :cancelled_usd_deposit)

    deposit = Bitex::UsdDeposit.find(id)
    deposit.cancel!

    deposit.should be_a Bitex::UsdDeposit
    deposit.status.should be :cancelled
    deposit.reason.should be :user_cancelled
  end

  it 'lists all usd deposits' do
    stub_private(:get, '/private/usd/deposits', :usd_deposits)

    deposits = Bitex::UsdDeposit.all

    deposits.should be_an Array
    deposits.first.should be_an Bitex::UsdDeposit
    deposits.first.status.should be :pending
  end
end
