require 'spec_helper'

describe Bitex::JsonApi::Ticker do
  let(:order_book_code) { :btc_usd }
  let(:resource_name) { described_class.name.demodulize.downcase.pluralize }

  shared_examples_for 'founded ticker' do
    it { response.should be_a(JsonApiClient::ResultSet) }

    its(:id) { should eq order_book_code.to_s }
    its(:type) { should eq resource_name }
    it { should be_a(described_class) }
  end

  describe '#all' do
    let(:response) { VCR.use_cassette('ticker') { described_class.all } }

    subject { response[0] }

    it_behaves_like 'founded ticker'

    it { response.uri.path.should eq "/api/#{resource_name}" }
    it { response.should be_any }
  end

  describe '#find' do
    context 'with invalid order book code' do
      subject { described_class.find('invalid_order_book_code') }

      it { expect { subject }.to raise_exception(Bitex::UnknownOrderBook) }
    end

    context 'with valid order book code' do
      let(:response) { VCR.use_cassette('ticker_for_order_book') { described_class.find(order_book_code) } }

      subject { response[0] }

      it_behaves_like 'founded ticker'

      it { response.uri.path.should eq "/api/#{resource_name}/#{order_book_code}" }
    end
  end
end
