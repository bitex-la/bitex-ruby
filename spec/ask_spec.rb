require 'spec_helper'

describe Bitex::JsonApi::Ask do
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:resource_name) { described_class.name.demodulize.downcase.pluralize }
  let(:valid_orderbook_code) { :btc_usd }
  let(:invalid_orderbook_code) { :invalid_orderbook_code }
  let(:read_level_key) { 'b47007918b1530b09bb972661c6588216a35f08e4fd9392e5c7348e0e3e4ffbd8a47ae4d22277576' }
  let(:write_level_key) { '2648e33d822a4cc51ae4ef28efed716a1ad8c37700d6b33a4295618ba880ffcf9b57e457e6594a35' }

  shared_examples_for 'Ask' do
    it { is_expected.to be_a(described_class) }

    its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id amount remaining_amount price status]) }
    its(:type) { is_expected.to eq(resource_name) }
  end

  describe '.find' do
    subject { client.asks.find(orderbook_code: orderbook_code, id: order_id) }

    context 'with invalid orderbook code' do
      let(:key) { :we_dont_care }
      let(:orderbook_code) { invalid_orderbook_code }
      let(:order_id) { :we_dont_care }

      it { expect { subject }.to raise_exception(Bitex::UnknownOrderbook) }
    end

    context 'with valid orderbook code' do
      let(:orderbook_code) { valid_orderbook_code }

      context 'with any level key' do
        let(:key) { read_level_key }

        context 'with non-existent id', vcr: { cassette_name: 'asks/find/non_existent_id' } do
          let(:order_id) { '99' }

          it { expect { subject }.to raise_exception(JsonApiClient::Errors::NotFound) }
        end

        context 'with any level key', vcr: { cassette_name: 'asks/find/successful' } do
          let(:order_id) { '22' }

          it_behaves_like 'Ask'

          its(:status) { is_expected.to eq('executing') }
        end
      end
    end
  end

  describe '.create' do
    subject { client.asks.create(orderbook_code: orderbook_code, amount: amount, price: price) }

    let(:amount) { 100.23 }
    let(:price) { 50.2 }

    context 'with invalid orderbook code' do
      let(:key) { :we_dont_care }
      let(:orderbook_code) { invalid_orderbook_code }

      it { expect { subject }.to raise_exception(Bitex::UnknownOrderbook) }
    end

    context 'with valid orderbook code' do
      let(:orderbook_code) { valid_orderbook_code }

      context 'with unauthorized level key', vcr: { cassette_name: 'asks/create/unauthorized_key' } do
        let(:key) { read_level_key }

        it { expect { subject }.to raise_exception(JsonApiClient::Errors::NotAuthorized) }
      end

      context 'with authorized level key' do
        let(:key) { write_level_key }

        context 'with zero amount' do
          let(:amount) { 0 }

          it { expect { subject }.to raise_exception(Bitex::InvalidArgument) }
        end

        context 'with amounts lower than allowed', vcr: { cassette_name: 'asks/create/lower_amount' } do
          let(:amount) { 0.00_000_001 }

          it { expect { subject }.to raise_exception(Bitex::OrderNotPlaced).with_message('La orden es muy pequeña') }
        end

        context 'insufficient funds', vcr: { cassette_name:  'asks/create/insufficient_funds' } do
          let(:amount) { 12_000_000 }

          it_behaves_like 'Ask'

          its(:amount) { is_expected.to eq(amount) }
          its(:price) { is_expected.to eq(price) }
          its(:status) { is_expected.to eq('cancelled') }
          its(:remaining_amount) { is_expected.to eq(amount) }
        end

        context 'enough funds', vcr: { cassette_name: 'asks/create/successful' } do
          it_behaves_like 'Ask'

          its(:amount) { is_expected.to eq(amount) }
          its(:price) { is_expected.to eq(price) }
          its(:status) { is_expected.to eq('executing') }
          its(:remaining_amount) { is_expected.to eq(41.40_647_059) }
        end
      end
    end
  end
end
