require 'spec_helper'

describe Bitex::JsonApi::Market do
  let(:client) { Bitex::Client.new }
  let(:orderbook_code) { :btc_usd }
  let(:resource_name) { described_class.name.demodulize.downcase.pluralize }

  describe '.find' do
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
      let(:response) { client.markets.find(orderbook_code) }

      subject { response[0] }

      shared_examples_for 'founded market' do
        it { expect(response.uri.path).to eq("/api/#{resource_name}/#{orderbook_code}") }
        it { expect(response).to be_a(JsonApiClient::ResultSet) }

        it { is_expected.to be_a(described_class) }

        its(:id) { is_expected.to eq(orderbook_code.to_s) }
        its(:type) { is_expected.to eq(resource_name) }
        its(:'relationships.attributes.keys') { is_expected.to eq(%w[candles transactions bids asks]) }
      end

      context 'without resources parametes', vcr: { cassette_name: 'market' } do
        it_behaves_like 'founded market'

        its(:'asks.sample.type') { is_expected.to eq('order_groups') }
        its(:'bids.sample.type') { is_expected.to eq('order_groups') }
        its(:'candles.sample.type') { is_expected.to eq('candles') }
        its(:'transactions.sample.type') { is_expected.to eq('transactions') }
      end

      context 'only some of the fields provided' do
        let(:response) { client.markets.find(orderbook_code, resource) }

        subject { response[0] }

        shared_examples_for 'market with included' do |resource|
          it_behaves_like 'founded market'

          it { expect(response.uri.query).to eq("include=#{resource}") }

          it { expect(subject.send(resource)).to be_any }
          it { expect(subject.send(resource)).to be_an(Array) }
        end

        context 'asks', vcr: { cassette_name: 'market_with_asks' } do
          let(:resource) { :asks }

          it_behaves_like 'market with included', :asks

          its(:'asks.sample.type') { is_expected.to eq('order_groups') }
        end

        context 'bids', vcr: { cassette_name: 'market_with_bids' } do
          let(:resource) { :bids }

          it_behaves_like 'market with included', :bids

          it { subject.bids.sample.type.should eq 'order_groups' }
        end

        context 'candles', vcr: { cassette_name: 'market_with_candles' } do
          let(:resource) { :candles }

          it_behaves_like 'market with included', :candles

          it { subject.candles.sample.type.should eq 'candles' }
        end

        context 'transactions', vcr: { cassette_name: 'market_with_transactions' } do
          let(:resource) { :transactions }

          it_behaves_like 'market with included', :transactions

          it { subject.transactions.sample.type.should eq 'transactions' }
        end
      end
    end
  end

  describe '.transsactions' do
    before(:each) { Timecop.freeze(time) }
    after(:each) { Timecop.return }

    let(:time) { Time.at(1535466933) }

    subject { response[0].transactions }

    shared_examples_for 'market transactions' do
      it { expect(response.uri.path).to eq("/api/markets/#{orderbook_code}/transactions") }
      it { expect(response).to be_a(JsonApiClient::ResultSet) }

      its(:'sample.type') { is_expected.to eq('transactions') }
    end

    context 'without filter', vcr: { cassette_name: 'market_transactions' } do
      let(:response) { client.markets.transactions(orderbook_code) }

      it { expect(response.uri.query).to be_nil }

      it_behaves_like 'market transactions'

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

      it { expect(URI.unescape(response.uri.query)).to eq("filter[from]=#{from}") }

      it_behaves_like 'market transactions'

      it 'has reducted to last 6 hours' do
        expect(Time.at(subject[0].timestamp)).to eq(6.hours.ago)
        expect(Time.at(subject[1].timestamp)).to eq(3.hours.ago)
      end
    end
  end

  describe '.candles' do
    subject { response[0] }

    shared_examples_for 'market candles' do
      it { expect(response.uri.path).to eq("/api/markets/#{orderbook_code}/candles") }
      it { expect(response).to be_a(JsonApiClient::ResultSet) }

      its(:'candles.sample.type') { is_expected.to eq('candles') }
    end

    context 'without filter', vcr: { cassette_name: 'market_candles' } do
      let(:response) { client.markets.candles(orderbook_code) }

      it_behaves_like 'market candles'

      it { response.uri.query.should be_nil }
    end

    context 'with from filter', vcr: { cassette_name: 'market_candles_with_from' } do
      let(:from) { 7 }

      let(:response) { client.markets.candles(orderbook_code, from: from) }

      it_behaves_like 'market candles'

      it { URI.unescape(response.uri.query).should eq "filter[from]=#{from}"  }

      context 'and with span query', vcr: { cassette_name: 'market_candles_with_span' } do
        let(:span) { 24 }

        let(:response) { client.markets.candles(orderbook_code, from: from, span: span) }

        it_behaves_like 'market candles'

        it { URI.unescape(response.uri.query).should eq "filter[from]=#{from}&span=#{span}" }
      end
    end
  end
end
