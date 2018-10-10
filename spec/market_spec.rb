require 'spec_helper'

describe Bitex::JsonApi::Market do
  let(:client) { Bitex::Client.new }
  let(:orderbook_code) { :btc_usd }
  let(:resource_name) { described_class.name.demodulize.downcase.pluralize }

  describe '.find' do
    subject { response[0] }

    context 'with invalid orderbook code' do
      let(:response) { client.markets.find('invalid_orderbook_code') }

      it { expect { response }.to raise_exception(Bitex::UnknownOrderBook) }
    end

    context 'with invalid resources' do
      let(:response) { client.markets.find(orderbook_code, from: from) }

      context 'with no numeric value' do
        let(:from) { '1234' }

        it { expect { response }.to raise_exception(Bitex::InvalidResourceArgument) }
      end

      context 'with negative number' do
        let(:from) { -3 }

        it { expect { response }.to raise_exception(Bitex::InvalidResourceArgument) }
      end
    end

    context 'with valid resources' do
      shared_examples_for 'Market responses' do
        it { is_expected.to be_a(described_class) }

        its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id]) }
        its(:id) { is_expected.to eq(orderbook_code.to_s) }
        its(:type) { is_expected.to eq(resource_name) }
      end

      context 'without resources parameters', vcr: { cassette_name: 'market' } do
        let(:response) { client.markets.find(orderbook_code) }

        it_behaves_like 'Market responses'
      end

      context 'about included resources' do
        let(:response) { client.markets.find(orderbook_code, resource) }

        context 'asks', vcr: { cassette_name: 'market_with_asks' } do
          let(:resource) { :asks }

          it_behaves_like 'Market responses'

          its(:'asks.sample.type') { is_expected.to eq('order_groups') }
        end

        context 'bids', vcr: { cassette_name: 'market_with_bids' } do
          let(:resource) { :bids }

          it_behaves_like 'Market responses'

          its(:'bids.sample.type') { is_expected.to eq('order_groups') }
        end

        context 'candles', vcr: { cassette_name: 'market_with_candles' } do
          let(:resource) { :candles }

          it_behaves_like 'Market responses'

          its(:'candles.sample.type') { is_expected.to eq('candles') }
        end

        context 'transactions', vcr: { cassette_name: 'market_with_transactions' } do
          let(:resource) { :transactions }

          it_behaves_like 'Market responses'

          its(:'transactions.sample.type') { is_expected.to eq('transactions') }
        end
      end
    end
  end

  describe '.transactions' do
    before(:each) { Timecop.freeze(time) }
    after(:each) { Timecop.return }

    let(:time) { Time.at(1535466933) }

    subject { response[0].transactions }

    shared_examples_for 'Market responses' do
      subject { response[0] }

      it { is_expected.to be_a(Bitex::JsonApi::Transaction) }

      its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id]) }
      its(:id) { is_expected.to eq(orderbook_code.to_s) }
      its(:type) { is_expected.to eq(resource_name) }
    end

    shared_examples_for 'Market transactions' do
      it { is_expected.to be_a(Array) }

      its(:'sample.attributes.keys') { is_expected.to contain_exactly(*%w[type id timestamp price amount]) }
      its(:'sample.type') { is_expected.to eq('transactions') }
    end

    context 'without filter', vcr: { cassette_name: 'market_transactions' } do
      let(:response) { client.markets.transactions(orderbook_code) }

      it_behaves_like 'Market responses'
      it_behaves_like 'Market transactions'

      it 'has all transactions' do
        expect(Time.at(subject[0].timestamp)).to eq(24.hours.ago)
        expect(Time.at(subject[1].timestamp)).to eq(12.hours.ago)
        expect(Time.at(subject[2].timestamp)).to eq(6.hours.ago)
        expect(Time.at(subject[3].timestamp)).to eq(3.hours.ago)
      end
    end

    context 'with filter', vcr: { cassette_name: 'market_transactions_with_filter' } do
      let(:response) { client.markets.transactions(orderbook_code, from: from) }
      let(:from) { 6 }

      it_behaves_like 'Market responses'
      it_behaves_like 'Market transactions'

      it 'has reducted to last 6 hours' do
        expect(Time.at(subject[0].timestamp)).to eq(6.hours.ago)
        expect(Time.at(subject[1].timestamp)).to eq(3.hours.ago)
      end
    end
  end

  describe '.candles' do
    subject { response[0].candles }

    shared_examples_for 'Market responses' do
      subject { response[0] }

      it { is_expected.to be_a(Bitex::JsonApi::Candle) }

      its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id]) }
      its(:id) { is_expected.to eq(orderbook_code.to_s) }
      its(:type) { is_expected.to eq(resource_name) }
    end

    shared_examples_for 'Market candles' do
      it { is_expected.to be_a(Array) }

      its(:'sample.attributes.keys') { is_expected.to contain_exactly(*%w[type id timestamp low open close high volume price_before_last vwap]) }
      its(:'sample.type') { is_expected.to eq('candles') }
    end

    context 'without filter', vcr: { cassette_name: 'market_candles' } do
      let(:response) { client.markets.candles(orderbook_code) }

      it_behaves_like 'Market responses'
      it_behaves_like 'Market candles'
    end

    context 'with from filter', vcr: { cassette_name: 'market_candles_with_from' } do
      let(:response) { client.markets.candles(orderbook_code, from: from) }
      let(:from) { 7 }

      it_behaves_like 'Market responses'
      it_behaves_like 'Market candles'

      context 'and with span query', vcr: { cassette_name: 'market_candles_with_span' } do
        let(:response) { client.markets.candles(orderbook_code, from: from, span: span) }
        let(:span) { 24 }

        it_behaves_like 'Market candles'
      end
    end
  end
end
