require 'spec_helper'

describe Bitex::JsonApi::Ticker do
  let(:resource_name) { described_class.name.demodulize.downcase.pluralize }

  describe '#all' do
    let(:response) { VCR.use_cassette('order_book') { described_class.all } }

    subject { response[0] }

    it { response.uri.path.should eq "/api/#{resource_name}" }
    it { response.should be_any }
    it { response.should be_a(JsonApiClient::ResultSet) }
    it { response.map(&:id).should contain_exactly(*Bitex::ORDER_BOOKS.keys.map(&:to_s)) }

    its(:type) { should eq resource_name }
    it { should be_a(described_class) }
  end
end
