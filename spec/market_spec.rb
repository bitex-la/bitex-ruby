require 'spec_helper'

describe Bitex::JsonApi::Market do
  let(:client) { build(:client) }
  let(:markets) { client.markets }
  let(:order_book_code) { :btc_usd }

  describe '#find' do
    subject(:market) { VCR.use_cassette('market') { described_class.find(order_book_code) } }

    it { should be_a(described_class) }
    its(:type) { should eq 'markets'}
    its(:id) { should eq order_book_code.to_s }
    it { subject.relationships.attributes.keys.should eq %w[candles transactions bids asks] }
  end

  context '#transactions' do
    let(:transactions) { VCR.use_cassette('market/transaction') { described_class.transactions(order_book_code) } }
    subject(:transaction) { transactions.sample }

    it { transactions.should be_a(Array) }
    it { subject.type.should eq 'transactions' }
    it { subject.attributes.keys.should eq %w[type id timestamp price amount] }
  end

  describe '#candles' do
    let(:candles) { VCR.use_cassette('market/candle') { described_class.candles(order_book_code) } }
    subject(:candle) { candles.sample }

    it { candles.should be_a(Array) }
    it { subject.type.should eq 'candles' }
    it { subject.attributes.keys.should eq %w[type id timestamp low open close high volume price_before_last vwap] }
  end

  describe '#asks' do
    let(:market) { VCR.use_cassette('market') { described_class.find(order_book_code) } }
    let(:asks) { market.asks }
    subject(:ask) { asks.sample }

    it { asks.should be_a(Array) }
    it { should be_a(Bitex::JsonApi::OrderGroup) }
    its(:type) { should eq 'order_groups' }
  end

  describe '#bids' do
    let(:market) { VCR.use_cassette('market') { described_class.find(order_book_code) } }
    let(:bids) { market.bids }
    subject(:bid) { bids.sample }

    it { bids.should be_a(Array) }
    it { should be_a(Bitex::JsonApi::OrderGroup) }
    its(:type) { should eq 'order_groups' }
  end
end
