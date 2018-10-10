require 'spec_helper'

describe Bitex::JsonApi::Orderbook do
  let(:client) { Bitex::Client.new }
  let(:orderbook_code) { :btc_usd }
  let(:resource_name) { described_class.name.demodulize.downcase.pluralize }

  describe '.all', vcr: { cassette_name: 'orderbook' } do
    subject { response.find { |orderbook| orderbook.code == orderbook_code.to_s } }

    let(:response) { client.orderbooks.all }

    it { is_expected.to be_a(described_class) }

    its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id code base quote]) }
    its(:type) { is_expected.to eq(resource_name) }
    its(:id) { is_expected.to eq(Bitex::ORDER_BOOKS[orderbook_code].to_s) }
    its(:code) { is_expected.to eq(orderbook_code.to_s) }

    it { expect(response.map { |ob| [ob[:code].to_sym, ob[:id].to_i] }.to_h).to contain_exactly(*Bitex::ORDER_BOOKS) }
  end
end
