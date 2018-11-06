require 'spec_helper'

describe Bitex::JsonApi::CoinWithdrawal do
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:read_level_key) { 'b47007918b1530b09bb972661c6588216a35f08e4fd9392e5c7348e0e3e4ffbd8a47ae4d22277576' }
  let(:write_level_key) { '2648e33d822a4cc51ae4ef28efed716a1ad8c37700d6b33a4295618ba880ffcf9b57e457e6594a35' }

  shared_examples_for 'Coin Withdrawal' do
    it { is_expected.to be_a(described_class) }

    its(:'attributes.keys') { is_expected.to contain_exactly(*%w[id type currency amount label status to_addresses]) }
    its(:type) { is_expected.to eq(resource_name) }
    its(:currency) { is_expected.to eq(currency) }
    its(:amount) { is_expected.to eq(amount.to_f) }
    its(:label) { is_expected.to eq(label) }
    its(:status) { is_expected.to eq('received') }
    its(:to_addresses) { is_expected.to eq(to_addresses) }

    context 'about coins' do
      subject { super().relationships.coin[:data][:attributes] }

      its(:keys) { is_expected.to contain_exactly(*%w[id code name decimals]) }

      its([:id]) { is_expected.to eq(1) }
      its([:code]) { is_expected.to eq(currency.to_s) }
      its([:name]) { is_expected.to eq('bitcoin') }
      its([:decimals]) { is_expected.to eq(8) }
    end
  end

  describe '.create' do
    subject { client.coin_withdrawals.create(label: label, amount: amount,currency: currency, to_addresses: to_addresses, otp: otp) }

    let(:label) { 'we_dont_care' }
    let(:amount) { 100 }
    let(:currency) { 'btc' }
    let(:to_addresses) { 'mszEUK9E6E7n4SNcrjYH8Fr7ZTGP9n3dRb' }
    let(:otp) { '111111' }

    context 'with invalid currency' do
      let(:key) { 'we_dont_care' }
      let(:currency) { 'we_dont_care' }

      it { expect { subject }.to raise_error(Bitex::CurrencyError) }
    end

    context 'with unauthorized key', vcr: { cassette_name: 'coin_withdrawals/create/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with unauthorized level key', vcr: { cassette_name: 'coin_withdrawals/create/unauthorized_key' } do
      it_behaves_like 'Not enough level permissions'
    end

    context 'with authorized level key', vcr: { cassette_name: 'coin_withdrawals/create/authorized' } do
      let(:key) { write_level_key }

      let(:label) { 'label-test' }

      it_behaves_like 'Coin Withdrawal'
    end
  end

  describe '.valid_currency?' do
    subject { described_class.send(:valid_currency?, currency) }


    context 'with valid currency' do
      let(:currency) { %w[bch btc].sample }

      it { is_expected.to be_truthy }
    end

    context 'with invalid currency' do
      let(:currency) { :we_dont_care }

      it { is_expected.to be_falsey }
    end
  end
end
