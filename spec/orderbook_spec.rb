require 'spec_helper'

describe Bitex::JsonApi::Orderbook do
  let(:client) { Bitex::Client.new }
  let(:orderbook_code) { :btc_usd }
  let(:resource_name) { described_class.name.demodulize.downcase.pluralize }

  shared_examples_for 'API responses' do
    subject { response }

    it { is_expected.to be_a(JsonApiClient::ResultSet) }
    it { is_expected.to be_any }
  end

  describe '.all', vcr: { cassette_name: 'orderbook' } do
    let(:response) { client.orderbooks.all }

    subject { response.find { |orderbook| orderbook.code == orderbook_code.to_s } }

    it_behaves_like 'API responses'
    it { expect(response.uri.path).to eq("/api/#{resource_name}") }

    it { is_expected.to be_a(described_class) }
    its(:'attributes.keys') { is_expected.to eq(%w[type id code base quote]) }
    its(:type) { is_expected.to eq(resource_name) }
    its(:id) { is_expected.to eq(Bitex::ORDER_BOOKS[orderbook_code].to_s) }
    its(:code) { is_expected.to eq(orderbook_code.to_s) }

    it do
      expect(
        response.map(&:attributes).map do |orderbook|
          [orderbook[:code].to_sym, orderbook[:id].to_i]
        end.to_h
      ).to contain_exactly(*Bitex::ORDER_BOOKS)
    end
  end
end
