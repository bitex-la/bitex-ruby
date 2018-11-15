require 'spec_helper'

describe Bitex::Bid do
  let(:client) { Bitex::Client.new(api_key: key, sandbox: true) }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:read_level_key) { 'read_level_key' }
  let(:write_level_key) { 'write_level_key' }

  let(:valid_orderbook_code) { :btc_usd }
  let(:invalid_orderbook_code) { :invalid_orderbook_code }

  describe '.create' do
    subject { client.bids.create(orderbook_code: orderbook_code, amount: amount, price: price) }

    let(:amount) { 100.23 }
    let(:price) { 50.2 }

    it_behaves_like 'Invalid orderbook code'

    context 'with valid orderbook code' do
      let(:orderbook_code) { valid_orderbook_code }

      context 'with unauthorized key', vcr: { cassette_name: 'bids/create/unauthorized' } do
        it_behaves_like 'Not enough permissions'
      end

      context 'with unauthorized level key', vcr: { cassette_name: 'bids/create/unauthorized_key' } do
        it_behaves_like 'Not enough level permissions'
      end

      context 'with authorized level key' do
        let(:key) { write_level_key }

        it_behaves_like 'New order with zero amount'

        context 'with amounts lower than allowed', vcr: { cassette_name: 'bids/create/lower_amount' } do
          it_behaves_like 'Very small order'
        end

        context 'insufficient funds', vcr: { cassette_name:  'bids/create/insufficient_funds' } do
          it_behaves_like 'Not enough funds'
        end

        context 'enough funds', vcr: { cassette_name: 'bids/create/authorized' } do
          it_behaves_like 'Successful new order'
        end
      end
    end
  end

  describe '.find' do
    subject { client.bids.find(orderbook_code: orderbook_code, id: id) }

    it_behaves_like 'Invalid orderbook code'

    context 'with valid orderbook code' do
      let(:orderbook_code) { valid_orderbook_code }

      context 'with unauthorized key', vcr: { cassette_name: 'bids/find/unauthorized' } do
        let(:id) { 22 }

        it_behaves_like 'Not enough permissions'
      end

      context 'with any level key' do
        let(:key) { read_level_key }

        context 'with non-existent id', vcr: { cassette_name: 'bids/find/non_existent_id' } do
          it_behaves_like 'Not Found'
        end

        context 'with existent id', vcr: { cassette_name: 'bids/find/authorized' } do
          let(:id) { 22 }

          it_behaves_like 'Order'
        end
      end
    end
  end

  describe '.cancel!' do
    subject { client.bids.cancel!(orderbook_code: orderbook_code, ids: [id]) }

    it_behaves_like 'Invalid orderbook code'

    context 'with valid orderbook code' do
      let(:orderbook_code) { valid_orderbook_code }

      context 'with unauthorized key', vcr: { cassette_name: 'bids/cancel/unauthorized' } do
        let(:id) { 22 }

        it_behaves_like 'Not enough permissions'
      end

      context 'with unauthorized level key', vcr: { cassette_name: 'bids/cancel/unauthorized_key' } do
        let(:id) { 22 }

        it_behaves_like 'Not enough level permissions'
      end

      context 'with authorized level key' do
        let(:key) { write_level_key }

        context 'with non-existent id', vcr: { cassette_name: 'bids/cancel/non_existent_id' } do
          let(:id) { 99 }

          it_behaves_like 'Cancelling order'
        end

        context 'with existent id', vcr: { cassette_name: 'bids/cancel/authorized' } do
          let(:id) { 22 }

          it_behaves_like 'Cancelling order'
        end
      end
    end
  end

  it_behaves_like '.resource_type', 'bids'

  it_behaves_like '.valid_code?'

  it_behaves_like '.valid_amount?'

  it_behaves_like '.json_api_body_parser'

  it_behaves_like '.to_json_api_body', 'bids'
end
