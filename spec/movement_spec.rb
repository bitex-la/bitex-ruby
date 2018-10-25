require 'spec_helper'

describe Bitex::JsonApi::Movement do
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:resource_name) { described_class.name.demodulize.downcase.pluralize }
  let(:read_level_key) { 'b47007918b1530b09bb972661c6588216a35f08e4fd9392e5c7348e0e3e4ffbd8a47ae4d22277576' }
  let(:write_level_key) { '2648e33d822a4cc51ae4ef28efed716a1ad8c37700d6b33a4295618ba880ffcf9b57e457e6594a35' }

  describe '.all' do
    subject { client.movements.all }

    context 'with unauthorized key', vcr: { cassette_name: 'movements/all/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with any level key', vcr: { cassette_name: 'movements/all/authorized' } do
      let(:key) { read_level_key }

      it { is_expected.to be_a(JsonApiClient::ResultSet) }

      context 'taking a sample' do
        subject { super().sample }

        it { is_expected.to be_a(described_class) }

        its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id timestamp currencies_involved currency amount fee fee_decimals fee_currency price price_decimals kind]) }
        its(:type) { is_expected.to eq(resource_name) }
      end
    end
  end
end
