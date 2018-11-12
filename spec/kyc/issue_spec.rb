require 'spec_helper'

describe Bitex::JsonApi::KYC::Issue do
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:read_level_key) { '742e8a9d71ef07e1a7ef9901972a82fff24e8ab2c2eb726f87dafa65768a7de11e9dc19ca9fc3efe' }
  let(:write_level_key) { 'cf35ed969e27d8434e865f673f9882c274370cff823a04b6b2acfc9e022fbb13882dd9a86f367a9b' }

  shared_examples_for 'Issue' do
    it { is_expected.to be_a(described_class) }

    its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id state created_at updated_at]) }

    context 'about relationships' do
      subject { super().relationships }

      its(:person) { is_expected.to be_present }
      its(:natural_docket_seed) { is_expected.to be_present }
      its(:legal_entity_docket_seed) { is_expected.to be_present }
      its(:argentina_invoicing_detail_seed) { is_expected.to be_present }
      its(:chile_invoicing_detail_seed) { is_expected.to be_present }
      its(:identification_seeds) { is_expected.to be_present }
      its(:domicile_seeds) { is_expected.to be_present }
      its(:phone_seeds) { is_expected.to be_present }
      its(:email_seeds) { is_expected.to be_present }
      its(:allowance_seeds) { is_expected.to be_present }
      its(:observations) { is_expected.to be_present }
      its(:note_seeds) { is_expected.to be_present }
    end
  end

  describe '.current!' do
    subject { client.issues.current! }

    context 'with unauthorized key', vcr: { cassette_name: 'kyc/issues/current/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with unauthorized level key', vcr: { cassette_name: 'kyc/issues/current/unauthorized_key' } do
      it_behaves_like 'Not enough level permissions'
    end

    context 'with authorized level key', vcr: { cassette_name: 'kyc/issues/current/authorized' } do
      let(:key) { write_level_key }

      it_behaves_like 'Issue'
    end
  end
end
