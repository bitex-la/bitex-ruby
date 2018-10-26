require 'spec_helper'

describe Bitex::JsonApi::Market do
  let(:client) { Bitex::Client.new }
  let(:orderbook_code) { :btc_usd }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }

  describe '.find' do
    context 'with raise condition' do
      context 'with invalid orderbook code' do
        subject { -> { client.markets.find('invalid_orderbook_code') } }

        it { is_expected.to raise_exception(Bitex::UnknownOrderbook) }
      end

      context 'with invalid resources' do
        subject { -> { client.markets.find(orderbook_code, from: from) } }

        context 'with no numeric value' do
          let(:from) { '1234' }

          it { is_expected.to raise_exception(Bitex::InvalidResourceArgument) }
        end

        context 'with negative number' do
          let(:from) { -3 }

          it { is_expected.to raise_exception(Bitex::InvalidResourceArgument) }
        end
      end
    end

    context 'with valid resources' do
      shared_examples_for 'Market' do
        it { is_expected.to be_a(described_class) }

        its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id]) }
        its(:id) { is_expected.to eq(orderbook_code.to_s) }
        its(:type) { is_expected.to eq(resource_name) }
      end

      context 'without resources parameters', vcr: { cassette_name: 'markets/market' } do
        subject { client.markets.find(orderbook_code) }

        it_behaves_like 'Market'
      end

      context 'about included resources' do
        subject { client.markets.find(orderbook_code, resource) }

        let(:sample) { subject.send(resource).sample }

        context 'asks', vcr: { cassette_name: 'markets/with_resources/asks' } do
          let(:resource) { :asks }

          it_behaves_like 'Market'

          it { expect(sample.type).to eq('order_groups') }
        end

        context 'bids', vcr: { cassette_name: 'markets/with_resources/bids' } do
          let(:resource) { :bids }

          it_behaves_like 'Market'

          it { expect(sample.type).to eq('order_groups') }
        end

        context 'candles', vcr: { cassette_name: 'markets/with_resources/candles' } do
          let(:resource) { :candles }

          it_behaves_like 'Market'

          it { expect(sample.type).to eq('candles') }
        end

        context 'transactions', vcr: { cassette_name: 'markets/with_resources/transactions' } do
          let(:resource) { :transactions }

          it_behaves_like 'Market'

          it { expect(sample.type).to eq('transactions') }
        end
      end
    end
  end

  describe '.candles' do
    subject { response.candles }

    shared_examples_for 'Market candles' do
      it { is_expected.to be_a(Array) }

      its(:'sample.attributes.keys') { is_expected.to contain_exactly(*%w[type id timestamp low open close high volume price_before_last vwap]) }
      its(:'sample.type') { is_expected.to eq('candles') }
    end

    shared_examples_for 'Market' do
      subject { response }

      it { is_expected.to be_a(Bitex::JsonApi::Candle) }

      its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id]) }
      its(:id) { is_expected.to eq(orderbook_code.to_s) }
      its(:type) { is_expected.to eq(resource_name) }
    end

    context 'without filter', vcr: { cassette_name: 'markets/candles/all' } do
      let(:response) { client.markets.candles(orderbook_code) }

      it_behaves_like 'Market'
      it_behaves_like 'Market candles'
    end

    context 'with from filter', vcr: { cassette_name: 'markets/candles/with_from' } do
      let(:response) { client.markets.candles(orderbook_code, from: from) }
      let(:from) { 7 }

      it_behaves_like 'Market'
      it_behaves_like 'Market candles'

      context 'and with span query', vcr: { cassette_name: 'markets/candles/with_span' } do
        let(:response) { client.markets.candles(orderbook_code, from: from, span: span) }
        let(:span) { 24 }

        it_behaves_like 'Market candles'
      end
    end
  end

  describe '.transactions' do
    before(:each) { Timecop.freeze(time) }
    after(:each) { Timecop.return }

    let(:time) { Time.at(1535466933) }

    subject { response.transactions }

    shared_examples_for 'Market transactions' do
      it { is_expected.to be_a(Array) }

      its(:'sample.attributes.keys') { is_expected.to contain_exactly(*%w[type id timestamp price amount]) }
      its(:'sample.type') { is_expected.to eq('transactions') }
    end

    shared_examples_for 'Market' do
      subject { response }

      it { is_expected.to be_a(Bitex::JsonApi::Transaction) }

      its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id]) }
      its(:id) { is_expected.to eq(orderbook_code.to_s) }
      its(:type) { is_expected.to eq(resource_name) }
    end

    context 'without filter', vcr: { cassette_name: 'markets/transactions/all' } do
      let(:response) { client.markets.transactions(orderbook_code) }

      it_behaves_like 'Market'
      it_behaves_like 'Market transactions'

      it 'has all transactions' do
        expect(Time.at(subject[0].timestamp)).to eq(24.hours.ago)
        expect(Time.at(subject[1].timestamp)).to eq(12.hours.ago)
        expect(Time.at(subject[2].timestamp)).to eq(6.hours.ago)
        expect(Time.at(subject[3].timestamp)).to eq(3.hours.ago)
      end
    end

    context 'with filter', vcr: { cassette_name: 'markets/transactions/with_filter' } do
      let(:response) { client.markets.transactions(orderbook_code, from: from) }
      let(:from) { 6 }

      it_behaves_like 'Market'
      it_behaves_like 'Market transactions'

      it 'has reducted to last 6 hours' do
        expect(Time.at(subject[0].timestamp)).to eq(6.hours.ago)
        expect(Time.at(subject[1].timestamp)).to eq(3.hours.ago)
      end
    end
  end
end
