require 'spec_helper'

describe Bitex::ApiKey do
  let(:client) { Bitex::Client.new(api_key: key, sandbox: true) }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:read_level_key) { 'read_level_key' }
  let(:write_level_key) { 'write_level_key' }

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
    subject { client.api_keys.create(permissions: permission, otp: code) }

    context 'with invalid otp cade' do
      let(:code) { 'invalid_code' }
      let(:key) { :we_dont_care }
      let(:permission) { { write: :we_dont_care } }

      it { expect { subject }.to raise_error(Bitex::MalformedOtp) }
    end

    context 'with valid otp code' do
      let(:code) { '984176' }
      let(:permission) { { write: :we_dont_care } }

      context 'with unauthorized key', vcr: { cassette_name: 'api_keys/create/unauthorized' } do
        let(:permission) { { write: true } }

        it_behaves_like 'Not enough permissions'
      end

      context 'with unauthorized level key', vcr: { cassette_name: 'api_keys/create/unauthorized_key' } do
        let(:permission) { { write: true } }

        it_behaves_like 'Not enough level permissions'
      end

      context 'with authorized level key' do
        let(:key) { write_level_key }

        context 'a new read level', vcr: { cassette_name: 'api_keys/create/authorized_read_level' } do
          let(:permission) { { write: false } }

          it_behaves_like 'Api Key'

          its(:write) { is_expected.to be_falsey }
        end

        context 'a new write level', vcr: { cassette_name: 'api_keys/create/authorized_write_level' } do
          let(:permission) { { write: true } }

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
