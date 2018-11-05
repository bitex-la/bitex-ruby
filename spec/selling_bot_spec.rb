require 'spec_helper'

describe Bitex::JsonApi::SellingBot do
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:read_level_key) { 'b47007918b1530b09bb972661c6588216a35f08e4fd9392e5c7348e0e3e4ffbd8a47ae4d22277576' }
  let(:write_level_key) { '2648e33d822a4cc51ae4ef28efed716a1ad8c37700d6b33a4295618ba880ffcf9b57e457e6594a35' }

  describe '.all' do
    subject { client.selling_bots.all }

    context 'with unauthorized key', vcr: { cassette_name: 'selling_bots/all/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with any level key' do
      let(:key) { read_level_key }

      context 'enough funds', vcr: { cassette_name: 'selling_bots/all/authorized' } do
        it { is_expected.to be_a(JsonApiClient::ResultSet) }

        context 'taking a sample' do
          subject { super().sample }

          it_behaves_like 'Trading Bot'
        end
      end
    end
  end

  describe '.create' do
    subject { client.selling_bots.create(amount: amount, orderbook_id: orderbook_id) }

    let(:amount) { 100 }
    let(:orderbook_id) { '1' }

    context 'with unauthorized key', vcr: { cassette_name: 'selling_bots/create/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with unauthorized level key', vcr: { cassette_name: 'selling_bots/create/unauthorized_key' } do
      it_behaves_like 'Not enough level permissions'
    end

    context 'with authorized level key', vcr: { cassette_name: 'selling_bots/create/authorized' } do
      let(:key) { write_level_key }

      it_behaves_like 'Trading Bot'
      its(:amount) { is_expected.to eq(amount) }

      context 'about Orderbook' do
        subject { super().relationships.orderbook[:data] }

        it_behaves_like 'Trading Bot Orderbook'
      end
    end
  end

  describe '.find' do
    subject { client.selling_bots.find(id: id) }

    let(:id) { '1' }

    context 'with unauthorized key', vcr: { cassette_name: 'selling_bots/find/unauthorized' } do

      it_behaves_like 'Not enough permissions'
    end

    context 'with any level key' do
      let(:key) { read_level_key }

      context 'with non-existent id', vcr: { cassette_name: 'selling_bots/find/non_existent_id' } do
        it_behaves_like 'Not Found'
      end

      context 'with existent id', vcr: { cassette_name: 'selling_bots/find/authorized' } do
        it_behaves_like 'Trading Bot'

        its(:id) { is_expected.to eq(id) }
      end
    end
  end

  describe '.cancel!' do
    subject { client.selling_bots.cancel!(id: id) }

    let(:id) { '1' }

    context 'with unauthorized key', vcr: { cassette_name: 'selling_bots/cancel/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with unauthorized level key', vcr: { cassette_name: 'selling_bots/cancel/unauthorized_key' } do
      it_behaves_like 'Not enough level permissions'
    end

    context 'with authorized level key' do
      let(:key) { write_level_key }

      context 'with non-existent id', vcr: { cassette_name: 'selling_bots/cancel/non_existent_id' } do
        it_behaves_like 'Not Found'
      end

      context 'with existent id', vcr: { cassette_name: 'selling_bots/cancel/authorized' } do
        let(:id) { 1 }

        it_behaves_like 'Cancelling bot'
      end
    end
  end
end
