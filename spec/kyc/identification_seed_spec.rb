require 'spec_helper'

describe Bitex::JsonApi::KYC::IdentificationSeed do
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:read_level_key) { '742e8a9d71ef07e1a7ef9901972a82fff24e8ab2c2eb726f87dafa65768a7de11e9dc19ca9fc3efe' }
  let(:write_level_key) { 'cf35ed969e27d8434e865f673f9882c274370cff823a04b6b2acfc9e022fbb13882dd9a86f367a9b' }

  shared_examples_for 'Identification Seed' do
    it { is_expected.to be_a(described_class) }

    its(:'attributes.keys') do
      is_expected.to contain_exactly(
        *%w[type id identification_kind_code number issuer public_registry_authority public_registry_book
        public_registry_extra_data created_at updated_at]
      )
    end

    its(:identification_kind_code) { is_expected.to eq(identification_kind_code) }
    its(:number) { is_expected.to eq(number) }
    its(:issuer) { is_expected.to eq(issuer) }

    # TODO why returns nil?
    its(:public_registry_authority) { is_expected.to be_nil }
    its(:public_registry_book) { is_expected.to be_nil }
    its(:public_registry_extra_data) { is_expected.to be_nil }
  end

  describe '.create' do
    subject do
      client.identification_seeds.create(
        identification_kind_code: identification_kind_code,
        number: number,
        issuer: issuer,
        public_registry_authority: public_registry_authority,
        public_registry_book: public_registry_book,
        public_registry_extra_data: public_registry_extra_data
      )
    end

    let(:identification_kind_code) { 'national_id' }
    let(:number) { '12345678' }
    let(:issuer) { 'AR' }
    let(:public_registry_authority) { 'public registry authority' }
    let(:public_registry_book) { 'public registry book' }
    let(:public_registry_extra_data) { 'public registry extra data' }
 
    context 'with unauthorized key', vcr: { cassette_name: 'kyc/identification_seeds/create/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with unauthorized level key', vcr: { cassette_name: 'kyc/identification_seeds/create/unauthorized_key' } do
      it_behaves_like 'Not enough level permissions'
    end

    context 'with authorized level key', vcr: { cassette_name: 'kyc/identification_seeds/create/authorized' } do
      let(:key) { write_level_key }

      it_behaves_like 'Identification Seed'
    end
  end
end
