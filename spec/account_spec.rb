require 'spec_helper'

describe Bitex::Account do
  let(:client) { Bitex::Client.new(api_key: key, sandbox: true) }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:read_level_key) { 'read_level_key' }
  let(:write_level_key) { 'write_level_key' }

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
