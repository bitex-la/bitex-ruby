require 'spec_helper'

describe Bitex::JsonApi::Orderbook do
  let(:client) { Bitex::Client.new }
  let(:orderbook_code) { :btc_usd }
  let(:resource_name) { described_class.name.demodulize.downcase.pluralize }

  describe '.all', vcr: { cassette_name: 'orderbooks/all' } do
    subject { client.orderbooks.all }

    let(:orderbooks) { Bitex::ORDERBOOKS.map { |key, value| [key, value].map(&:to_s) }.to_h }

    it { is_expected.to be_a(JsonApiClient::ResultSet) }

    context 'taking a sample' do
      subject { super().sample }

      it { is_expected.to be_a(described_class) }

      its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id code base quote]) }
      its(:type) { is_expected.to eq(resource_name) }
      its(:id) { is_expected.to eq(orderbooks[subject.code]) }
      its(:code) { is_expected.to eq(orderbooks.key(subject.id)) }

      it { expect(orderbooks).to have_key(subject.code) }
    end
  end
end
