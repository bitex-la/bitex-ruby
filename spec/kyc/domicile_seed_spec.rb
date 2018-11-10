require 'spec_helper'

describe Bitex::JsonApi::KYC::DomicileSeed do
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:read_level_key) { '742e8a9d71ef07e1a7ef9901972a82fff24e8ab2c2eb726f87dafa65768a7de11e9dc19ca9fc3efe' }
  let(:write_level_key) { 'cf35ed969e27d8434e865f673f9882c274370cff823a04b6b2acfc9e022fbb13882dd9a86f367a9b' }

  shared_examples_for 'Domicile Seed' do
    it { is_expected.to be_a(described_class) }

    its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id city country floor postal_code street_address street_number state apartment created_at updated_at]) }

    its(:city) { is_expected.to eq(city) }
    its(:country) { is_expected.to eq(country) }
    its(:floor) { is_expected.to eq(floor) }
    its(:postal_code) { is_expected.to eq(postal_code) }
    its(:street_address) { is_expected.to eq(street_address) }
    its(:street_number) { is_expected.to eq(street_number) }
    its(:state) { is_expected.to eq(state) }
    its(:apartment) { is_expected.to eq(apartment) }
  end

  describe '.create' do
    subject do
      client.domicile_seeds.create(
        city: city,
        country: country,
        floor: floor,
        postal_code: postal_code,
        street_address: street_address,
        street_number: street_number,
        state: state,
        apartment: apartment
      )
    end

    let(:city) { 'CABA' }
    let(:country) { 'AR' }
    let(:floor) { '0' }
    let(:postal_code) { '1001' }
    let(:street_address) { 'Balcarce' }
    let(:street_number) { '50' }
    let(:state) { 'zaraza' }
    let(:apartment) { '9º B' }

    context 'with unauthorized key', vcr: { cassette_name: 'kyc/domicile_seeds/create/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with unauthorized level key', vcr: { cassette_name: 'kyc/domicile_seeds/create/unauthorized_key' } do
      it_behaves_like 'Not enough level permissions'
    end

    context 'with authorized level key', vcr: { cassette_name: 'kyc/domicile_seeds/create/authorized' } do
      let(:key) { write_level_key }

      it_behaves_like 'Domicile Seed'
    end
  end
end
