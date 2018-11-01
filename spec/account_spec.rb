require 'spec_helper'

describe Bitex::JsonApi::Account do
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:read_level_key) { 'b47007918b1530b09bb972661c6588216a35f08e4fd9392e5c7348e0e3e4ffbd8a47ae4d22277576' }
  let(:write_level_key) { '2648e33d822a4cc51ae4ef28efed716a1ad8c37700d6b33a4295618ba880ffcf9b57e457e6594a35' }

  describe '.all' do
    subject { client.accounts.all }

    context 'with unauthorized key', vcr: { cassette_name: 'accounts/all/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with authorized level key', vcr: { cassette_name: 'accounts/all/authorized' } do
      let(:key) { write_level_key }

      it { is_expected.to be_a(JsonApiClient::ResultSet) }

      context 'taking a sample' do
        subject { super().sample }

        it { is_expected.to be_a(described_class) }

        its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id balances country]) }
        its(:type) { is_expected.to eq(resource_name) }

        context 'about balances' do
          subject { super().balances }

          it { is_expected.to be_a(ActiveSupport::HashWithIndifferentAccess) }
          its(:keys) { is_expected.to contain_exactly(*%w[btc usd ars clp bch pyg uyu]) }

          context 'taking a btc balance' do
            subject { super()[:btc] }

            its(:keys) { is_expected.to contain_exactly(*%w[total available]) }
          end
        end
      end
    end
  end
end
