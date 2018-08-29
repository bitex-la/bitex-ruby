require 'spec_helper'

describe Bitex::JsonApi::Market do
  let(:order_book_code) { :btc_usd }
  let(:resource_name) { described_class.name.demodulize.downcase.pluralize }

  describe '#find' do
    context 'with invalid order book code' do
      let(:response) { described_class.find('invalid_order_book_code') }

      it { expect { response }.to raise_exception(Bitex::UnknownOrderBook) }
    end

    context 'with invalid resources' do
      let(:response) { described_class.find(order_book_code, from: from) }

      context 'with no numeric value' do
        let(:from) { '1234' }

        it { expect { response }.to raise_exception(Bitex::InvalidResourceArgument) }
      end

      context 'with negative number' do
        let(:from) { -3 }

        it { expect { response }.to raise_exception(Bitex::InvalidResourceArgument) }
      end
    end

    let(:response) { VCR.use_cassette('market') { described_class.find(order_book_code) } }

    subject { response[0] }

    shared_examples_for 'founded market' do
      it { response.uri.path.should eq "/api/#{resource_name}/#{order_book_code}" }
      it { response.should be_a(JsonApiClient::ResultSet) }

      its(:id) { should eq order_book_code.to_s }
      its(:type) { should eq resource_name }
      it { should be_a(described_class) }
      it { subject.relationships.attributes.keys.should eq %w[candles transactions bids asks] }
    end

    context 'without resources parametes' do
      it_behaves_like 'founded market'

      it { subject.asks.sample.type.should eq 'order_groups' }
      it { subject.bids.sample.type.should eq 'order_groups' }
      it { subject.candles.sample.type.should eq 'candles' }
      it { subject.transactions.sample.type.should eq 'transactions' }
    end

    context 'only some of the fields provided' do
      let(:response) { VCR.use_cassette(cassette_name) { described_class.find(order_book_code, resource) } }

      subject { response[0] }

      shared_examples_for 'market with included' do |resource|
        let(:resources) { %i[asks bids candles transactions].reject { |rsc| rsc == resource } }

        it_behaves_like 'founded market'

        it { response.uri.query.should eq "include=#{resource}" }

        it { subject.send(resource).should be_any }
        it { subject.send(resource).should be_an(Array) }
        it { resources.each { |rsc| subject.send(rsc).should be_empty } }
      end

      context 'asks' do
        let(:cassette_name) { 'market_with_asks' }
        let(:resource) { :asks }

        it_behaves_like 'market with included', :asks

        it { subject.asks.sample.type.should eq 'order_groups' }
      end

      context 'bids' do
        let(:cassette_name) { 'market_with_bids' }
        let(:resource) { :bids }

        it_behaves_like 'market with included', :bids

        it { subject.bids.sample.type.should eq 'order_groups' }
      end

      context 'candles' do
        let(:cassette_name) { 'market_with_candles' }
        let(:resource) { :candles }

        it_behaves_like 'market with included', :candles

        it { subject.candles.sample.type.should eq 'candles' }
      end

      context 'transactions' do
        let(:cassette_name) { 'market_with_transactions' }
        let(:resource) { :transactions }

        it_behaves_like 'market with included', :transactions

        it { subject.transactions.sample.type.should eq 'transactions' }
      end
    end
  end

  describe '#transsactions' do
    before(:each) { Timecop.freeze(time) }
    after(:each) { Timecop.return }

    let(:time) { Time.at(1535466933) }

    shared_examples_for 'market transactions' do
      it { response.uri.path.should eq "/api/markets/#{order_book_code}/transactions" }
      it { response.should be_a(JsonApiClient::ResultSet) }

      it { subject.should be_any }
      it { subject.sample.type.should eq 'transactions' }
    end

    context 'without filter' do
      let(:response) { VCR.use_cassette('market_transactions') { described_class.transactions(order_book_code) } }

      subject { response }

      it_behaves_like 'market transactions'

      it { response.uri.query.should be_nil }

      it { subject.count.should eq 4 }
      it 'has all transactions' do
        Time.at(subject[0].timestamp).should eq 24.hours.ago
        Time.at(subject[1].timestamp).should eq 12.hours.ago
        Time.at(subject[2].timestamp).should eq 6.hours.ago
        Time.at(subject[3].timestamp).should eq 3.hours.ago
      end
    end

    context 'with filter' do
      let(:response) { VCR.use_cassette('market_transactions_with_filter') { described_class.transactions(order_book_code, from: from) } }
      let(:from) { 6 }

      subject { response }

      it_behaves_like 'market transactions'

      it { URI.unescape(response.uri.query).should eq "filter[from]=#{from}" }

      it { subject.count.should eq 2 }
      it 'has reducted to last 6 hours' do
        Time.at(subject[0].timestamp).should eq 6.hours.ago
        Time.at(subject[1].timestamp).should eq 3.hours.ago
      end
    end
  end

  describe '#candles' do
    let(:response) { VCR.use_cassette('market_candles') { described_class.candles(order_book_code) } }

    subject { response }

    shared_examples_for 'market candles' do
      it { response.uri.path.should eq "/api/markets/#{order_book_code}/candles" }
      it { response.should be_a(JsonApiClient::ResultSet) }

      it { subject.should be_any }
      it { subject.sample.type.should eq 'candles' }
    end

    context 'without filter' do
      it_behaves_like 'market candles'

      it { response.uri.query.should be_nil }
    end

    context 'with from filter' do
      let(:from) { 7 }

      let(:response) { VCR.use_cassette('market_candles_with_from') { described_class.candles(order_book_code, from: from) } }

      it_behaves_like 'market candles'

      it { URI.unescape(response.uri.query).should eq "filter[from]=#{from}"  }

      context 'wtth span query' do
        let(:span) { 24 }

        let(:response) { VCR.use_cassette('market_candles_with_span') { described_class.candles(order_book_code, from: from, span: span) } }

        it_behaves_like 'market candles'

        it { URI.unescape(response.uri.query).should eq "filter[from]=#{from}&span=#{span}" }
      end
    end
  end
end
