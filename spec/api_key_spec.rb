require 'spec_helper'

describe Bitex::JsonApi::ApiKey do
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize } 
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:read_api_key) { '81a3008a9d0b65a31d3d16759da5a7fc3c597deac1a8f23afb671e0a8d4c29aae3b92604773d5234' }
  let(:write_api_key) { '0cbb224a57d59535bb3b0c92a99e7b2ac6d36514dbd48c667ccca09961937ca93740de334568cc05' }
  let(:write_level) { true }
  let(:read_level) { false }

  describe '.create' do
    context 'with invalid otp cade' do
      subject { -> { client.api_keys.create(write: level, otp_code: code) } }

      before(:each) { client.api_keys.stub(:valid_otp_code?).with(code) { false } }

      let(:key) { read_api_key }
      let(:level) { [read_level, write_level].sample }
      let(:code) { 'invalid_code' }

      it { is_expected.to raise_error(Bitex::MalformedOtpCode) }
    end

    context 'with valid otp code' do
      before(:each) { client.api_keys.stub(:valid_otp_code?).with(code) { true } }

      let(:code) { '984176' }

      context 'with read level api key client', vcr: { cassette_name: 'unauthorized_api_key_client' } do
        subject { -> { client.api_keys.create(write: level, otp_code: code) } }

        let(:key) { read_api_key }
        let(:level) { [read_level, write_level].sample }

        it { is_expected.to raise_error(JsonApiClient::Errors::NotAuthorized) }
      end

      context 'with a write level api key client' do
        subject { client.api_keys.create(write: level, otp_code: code) }

        let(:key) { write_api_key }

        shared_examples_for 'New API Key' do
          it { is_expected.to be_a(described_class) }
          its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type write meta id token]) }

          its(:type) { is_expected.to eq(resource_name) }
          its(:write) { level }
          its(:meta) { is_expected.to be_present }
          its(:meta) { is_expected.to eq({ 'otp' => code }) }

          its(:id) { is_expected.to be_present }
          its(:token) { is_expected.to be_present }
        end

        context 'a new read level api key', vcr: { cassette_name: 'new_read_level_api_key' } do
          let(:level) { read_level }

          it_behaves_like 'New API Key'
        end

        context 'a new write level api key', vcr: { cassette_name: 'new_write_level_api_key' } do
          let(:level) { write_level }

          it_behaves_like 'New API Key'
        end
      end
    end
  end
end
