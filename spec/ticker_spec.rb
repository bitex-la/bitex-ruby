require 'spec_helper'

describe Bitex::JsonApi::Ticker do
  let(:client) { Bitex::Client.new }
  let(:order_book_code) { :btc_usd }
  let(:resource_name) { described_class.name.demodulize.downcase.pluralize }

  shared_examples_for 'API responses' do
    subject { response }

    it { is_expected.to be_a(JsonApiClient::ResultSet) }
    it { is_expected.to be_any }
  end

  describe '.all', vcr: { cassette_name: 'ticker' } do
    let(:response) { client.tickers.all }

    subject { response[0] }

    it_behaves_like 'API responses'
    it { expect(response.uri.path).to eq("/api/#{resource_name}") }

    it { is_expected.to be_a(described_class) }
    its(:id) { is_expected.to eq(order_book_code.to_s) }
    its(:type) { is_expected.to eq(resource_name.singularize) }
  end

  describe '#find' do
    context 'with valid order book code', vcr: { cassette_name: 'ticker_for_valid_order_book' } do
      let(:response) { described_class.find(order_book_code) }

      subject { response[0] }

      it_behaves_like 'API responses'
      it { expect(response.uri.path).to eq("/api/#{resource_name}/#{order_book_code}") }
    end

    context 'with invalid order book code' do
      subject { described_class.find(:invalid_order_book_code) }

      it { expect { subject }.to raise_exception(Bitex::UnknownOrderBook) }
    end
  end
end
