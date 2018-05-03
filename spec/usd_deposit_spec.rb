require 'spec_helper'

describe Bitex::UsdDeposit do
  before(:each) { Bitex.api_key = 'valid_api_key' }

  let(:api_class_id) { 7 }
  let(:id) { 12_345_678 }
  let(:created_at) { 946_685_400 }
  let(:requested_amount) { 110.0 }
  let(:amount) { 100.0 }
  let(:deposit_method) { 1 }
  let(:status) { 1 }
  let(:reason) { 0 }
  let(:country) { 'UY' }
  let(:currency) { 'UYU' }
  let(:kyc_profile_id) { 1 }
  let(:request_details) { 'bank of new york mellon' }
  let(:astropay_response_body) { { 'status' => 'OK', 'link' => 'https://astr.com' } }
  let(:third_party_reference) { 'REFERENCE' }

  let(:as_json) do
    [api_class_id, id, created_at, requested_amount, amount, deposit_method, status, reason, country,
     currency, kyc_profile_id, request_details, astropay_response_body, third_party_reference]
  end

  it_behaves_like 'API class'

  context 'deserializing from json' do
    let(:deposit) { Bitex::UsdDeposit.from_json(as_json) }

    it 'sets amount as BigDecimal' do
      deposit.amount.should be_an BigDecimal
      deposit.amount.should eq amount
    end

    it 'sets requested amount as BigDecimal' do
      deposit.requested_amount.should be_an BigDecimal
      deposit.requested_amount.should eq requested_amount
    end

    it 'sets country' do
      deposit.country.should be_an String
      deposit.country.should eq country
    end

    it 'sets currency' do
      deposit.currency.should be_an String
      deposit.currency.should eq currency
    end

    it 'sets kyc profile' do
      deposit.kyc_profile_id.should be_an Integer
      deposit.kyc_profile_id.should be kyc_profile_id
    end

    it 'sets details' do
      deposit.request_details.should be_an String
      deposit.request_details.should eq request_details
    end

    it 'sets the astropay_response_body' do
      deposit.astropay_response_body.should be_an Hash
      deposit.astropay_response_body.keys.all? { |key| key.should be_an String }
      deposit.astropay_response_body.values.all? { |value| value.should be_an String }
      deposit.astropay_response_body.should eq astropay_response_body
    end

    it 'sets the third party reference' do
      deposit.third_party_reference.should be_an String
      deposit.third_party_reference.should eq third_party_reference
    end

    Bitex::UsdDeposit.deposit_methods.each do |code, deposit_method|
      it "sets deposit_method #{code} to #{deposit_method}" do
        as_json[5] = code
        deposit.deposit_method.should be deposit_method
      end
    end

    Bitex::UsdDeposit.statuses.each do |code, status|
      it "sets status #{code} to #{status}" do
        as_json[6] = code
        deposit.status.should be status
      end
    end

    Bitex::UsdDeposit.reasons.each do |code, reason|
      it "sets reason #{code} to #{reason}" do
        as_json[7] = code
        deposit.reason.should be reason
      end
    end

    it 'creates a new deposit' do
      stub_private(
        :post,
        '/private/usd/deposits',
        :usd_deposit,
        country: country, amount: amount, currency: currency, deposit_method: deposit_method, request_details: request_details
      )

      deposit = Bitex::UsdDeposit.create!(country, amount, currency, deposit_method, request_details)

      deposit.should be_an Bitex::UsdDeposit
      deposit.astropay_response_body.should be_an Hash
      deposit.status.should be :pending
    end

    it 'finds a single usd deposit' do
      stub_private(:get, "/private/usd/deposits/#{id}", :usd_deposit)

      deposit = Bitex::UsdDeposit.find(id)

      deposit.should be_an Bitex::UsdDeposit
      deposit.status.should be :pending
    end

    it 'cancels a deposit' do
      stub_private(:get, "/private/usd/deposits/#{id}", :usd_deposit)
      stub_private(:post, "/private/usd/deposits/#{id}/cancel", :cancelled_usd_deposit)

      deposit = Bitex::UsdDeposit.find(id).cancel!

      deposit.should be_an Bitex::UsdDeposit
      deposit.status.should be :cancelled
      deposit.reason.should be :user_cancelled
    end

    it 'lists all usd deposits' do
      stub_private(:get, '/private/usd/deposits', :usd_deposits)

      deposits = Bitex::UsdDeposit.all

      deposits.should be_an Array
      deposits.all? { |deposit| deposit.should be_an Bitex::UsdDeposit }
      deposits.all? { |deposit| deposit.status.should be :pending }
    end
  end
end
