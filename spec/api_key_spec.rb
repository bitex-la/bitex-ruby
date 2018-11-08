require 'spec_helper'

describe Bitex::JsonApi::ApiKey do
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:read_level_key) { '81a3008a9d0b65a31d3d16759da5a7fc3c597deac1a8f23afb671e0a8d4c29aae3b92604773d5234' }
  let(:write_level_key) { '0cbb224a57d59535bb3b0c92a99e7b2ac6d36514dbd48c667ccca09961937ca93740de334568cc05' }

  shared_examples_for 'Api Key' do
    it { is_expected.to be_a(described_class) }

    its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type write id token]) }

    its(:type) { is_expected.to eq(resource_name) }
    its(:id) { is_expected.to be_present }
    its(:token) { is_expected.to be_present }
    its(:write) { is_expected.to be_boolean }
  end

  describe '.all' do
    subject { client.api_keys.all }

    context 'with unauthorized key', vcr: { cassette_name: 'api_keys/all/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with any level key', vcr: { cassette_name: 'api_keys/all/authorized' } do
      let(:key) { read_level_key }

      it { is_expected.to be_a(JsonApiClient::ResultSet) }

      context 'taking a sample' do
        subject { super().sample }

        it_behaves_like 'Api Key'
      end
    end
  end

  describe '.create' do
    subject { client.api_keys.create(level: level, otp: code) }

    context 'with invalid otp cade' do
      let(:code) { 'invalid_code' }
      let(:key) { :we_dont_care }
      let(:level) { :we_dont_care }

      it { expect { subject }.to raise_error(Bitex::MalformedOtp) }
    end

    context 'with valid otp code' do
      let(:code) { '984176' }
      let(:level) { :we_dont_care }

      context 'with unauthorized key', vcr: { cassette_name: 'api_keys/create/unauthorized' } do
        let(:level) { :write }

        it_behaves_like 'Not enough permissions'
      end

      context 'with unauthorized level key', vcr: { cassette_name: 'api_keys/create/unauthorized_key' } do
        let(:level) { :write }

        it_behaves_like 'Not enough level permissions'
      end

      context 'with authorized level key' do
        let(:key) { write_level_key }

        context 'a new read level', vcr: { cassette_name: 'api_keys/create/authorized_read_level' } do
          let(:level) { :read }

          it_behaves_like 'Api Key'

          its(:write) { is_expected.to be_falsey }
        end

        context 'a new write level', vcr: { cassette_name: 'api_keys/create/authorized_write_level' } do
          let(:level) { :write }

          it_behaves_like 'Api Key'

          its(:write) { is_expected.to be_truthy }
        end
      end
    end
  end

  describe '.destroy' do
    subject { client.api_keys.new(id: id).destroy }

    let(:id) { 20 }

    context 'with unauthorized key', vcr: { cassette_name: 'api_keys/destroy/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with unauthorized level key', vcr: { cassette_name: 'api_keys/destroy/unauthorized_key' } do
      it_behaves_like 'Not enough level permissions'
    end

    context 'with authorized level key' do
      let(:key) { write_level_key }

      context 'with non-existent id', vcr: { cassette_name: 'api_keys/destroy/non_existent_id' } do
        it_behaves_like 'Not Found'
      end

      context 'with existent id', vcr: { cassette_name: 'api_keys/destroy/authorized' } do
        it { is_expected.to be_truthy }
      end
    end
  end
end
