require 'spec_helper'

describe Bitex::UsdWithdrawal do
  before(:each) { Bitex.api_key = 'valid_api_key' }

  let(:api_class_id) { 8 }
  let(:id) { 12_345_678 }
  let(:created_at) { 946_685_400 }
  let(:amount) { 100.0 }
  let(:status) { 1 }
  let(:reason) { 0 }
  let(:country) { 'UY' }
  let(:currency) { 'UYU' }
  let(:payment_method) { 1 }
  let(:label) { 'billy bob' }
  let(:kyc_profile_id) { 1 }
  let(:instructions) { 'instructions' }

  let(:as_json) do
    [api_class_id, id, created_at, amount, status, reason, country, currency, payment_method, label, kyc_profile_id, instructions]
  end

  it_behaves_like 'API class'

  context 'Deserializing from json' do
    let(:withdrawal) { Bitex::UsdWithdrawal.from_json(as_json) }

    it 'sets amount as BigDecimal' do
      withdrawal.amount.should be_an BigDecimal
      withdrawal.amount.should eq amount
    end

    it 'sets country' do
      withdrawal.country.should be_an String
      withdrawal.country.should eq country
    end

    it 'sets currency' do
      withdrawal.currency.should be_an String
      withdrawal.currency.should eq currency
    end

    it 'sets payment method' do
      withdrawal.payment_method.should be_an Symbol
      withdrawal.payment_method.should be Bitex::UsdWithdrawal.payment_methods[payment_method]
    end

    it 'sets label' do
      withdrawal.label.should be_an String
      withdrawal.label.should eq label
    end

    it 'sets kyc profile id' do
      withdrawal.kyc_profile_id.should be_an Integer
      withdrawal.kyc_profile_id.should be kyc_profile_id
    end

    it 'sets instructions' do
      withdrawal.instructions.should be_an String
      withdrawal.instructions.should eq instructions
    end

    Bitex::UsdWithdrawal.statuses.each do |code, status|
      it "sets status #{code} to #{status}" do
        as_json[4] = code
        withdrawal.status.should be status
      end
    end

    Bitex::UsdWithdrawal.reasons.each do |code, reason|
      it "sets reason #{code} to #{reason}" do
        as_json[5] = code
        withdrawal.reason.should be reason
      end
    end

    it 'creates a new withdrawal' do
      stub_private(
        :post,
        '/private/usd/withdrawals',
        :usd_withdrawal,
        country: country, amount: amount, currency: currency, payment_method: payment_method, instructions: instructions,
        label: label
      )

      withdrawal = Bitex::UsdWithdrawal.create!(country, amount, currency, payment_method, instructions, label)

      withdrawal.should be_an Bitex::UsdWithdrawal
      withdrawal.status.should == :received
    end

    it 'finds a single usd withdrawal' do
      stub_private(:get, "/private/usd/withdrawals/#{id}", :usd_withdrawal)

      withdrawal = Bitex::UsdWithdrawal.find(id)

      withdrawal.should be_an Bitex::UsdWithdrawal
      withdrawal.status.should == :received
    end

    it 'lists all usd withdrawals' do
      stub_private(:get, '/private/usd/withdrawals', :usd_withdrawals)

      withdrawals = Bitex::UsdWithdrawal.all

      withdrawals.should be_an Array
      withdrawals.all? { |withdrawal| withdrawal.should be_an Bitex::UsdWithdrawal }
      withdrawals.all? { |withdrawal| withdrawal.status.should be :received }
    end
  end
end
