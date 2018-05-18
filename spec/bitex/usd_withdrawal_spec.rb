require 'spec_helper'

describe Bitex::UsdWithdrawal do
  before(:each) { Bitex.api_key = 'valid_api_key' }

  let(:base_url) { '/private/usd/withdrawals' }

  let(:api_class_id) { 8 }
  let(:id) { 12_345_678 }
  let(:created_at) { 946_685_400 }
  let(:amount) { 100 }
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
    let(:withdrawal) { subject.class.from_json(as_json) }

    it 'sets amount as BigDecimal' do
      withdrawal.amount.should be_a(BigDecimal)
      withdrawal.amount.should eq amount
    end

    it 'sets country' do
      withdrawal.country.should be_a(String)
      withdrawal.country.should eq country
    end

    it 'sets currency' do
      withdrawal.currency.should be_a(String)
      withdrawal.currency.should eq currency
    end

    it 'sets payment method' do
      withdrawal.payment_method.should be_a(Symbol)
      withdrawal.payment_method.should eq subject.class.payment_methods[payment_method]
    end

    it 'sets label' do
      withdrawal.label.should be_a(String)
      withdrawal.label.should eq label
    end

    it 'sets kyc profile id' do
      withdrawal.kyc_profile_id.should be_an(Integer)
      withdrawal.kyc_profile_id.should eq kyc_profile_id
    end

    it 'sets instructions' do
      withdrawal.instructions.should be_a(String)
      withdrawal.instructions.should eq instructions
    end

    Bitex::UsdWithdrawal.statuses.each do |code, status|
      it "sets status #{code} to #{status}" do
        as_json[4] = code
        withdrawal.status.should eq status
      end
    end

    Bitex::UsdWithdrawal.reasons.each do |code, reason|
      it "sets reason #{code} to #{reason}" do
        as_json[5] = code
        withdrawal.reason.should eq reason
      end
    end
  end

  it 'creates a new withdrawal' do
    stub_private(
      :post,
      base_url,
      :usd_withdrawal,
      country: country, amount: amount, currency: currency, payment_method: payment_method, instructions: instructions,
      label: label
    )

    withdrawal = subject.class.create!(country, amount, currency, payment_method, instructions, label)

    withdrawal.should be_a(subject.class)
    withdrawal.status.should eq :received
  end

  it 'finds a single usd withdrawal' do
    stub_private(:get, "#{base_url}/#{id}", :usd_withdrawal)

    withdrawal = subject.class.find(id)

    withdrawal.should be_an(subject.class)
    withdrawal.id.should eq id
    withdrawal.status.should eq :received
  end

  it 'lists all usd withdrawals' do
    stub_private(:get, base_url, :usd_withdrawals)

    withdrawals = subject.class.all

    withdrawals.should be_an(Array)
    withdrawals.all? do |withdrawal|
      withdrawal.should be_a(subject.class)
      withdrawal.status.should be :received
    end
  end
end
