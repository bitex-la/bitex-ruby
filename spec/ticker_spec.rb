require 'spec_helper'

describe Bitex::JsonApi::Ticker do
  let(:client) { Bitex::Client.new }
  let(:order_book_code) { :btc_usd }
  let(:resource_name) { described_class.name.demodulize.downcase.pluralize }

  describe '.all', vcr: { cassette_name: 'tickers/all' } do
    subject { client.tickers.all }

    it { is_expected.to be_a(described_class) }

    its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id price]) }
    its(:id) { is_expected.to eq(order_book_code.to_s) }
    its(:type) { is_expected.to eq(resource_name.singularize) }
  end

  describe '.find' do
    context 'with invalid orderbook code' do
      subject { -> { described_class.find(:invalid_orderbook_code) } }

      it { is_expected.to raise_exception(Bitex::UnknownOrderbook) }
    end

    context 'with valid orderbook code', vcr: { cassette_name: 'tickers/ticker' } do
      subject { client.tickers.find(order_book_code) }

      its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id last open high low vwap volume bid ask price_before_last]) }
      its(:type) { is_expected.to eq(resource_name) }
    end
  end
end
