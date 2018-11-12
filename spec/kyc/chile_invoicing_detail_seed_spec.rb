require 'spec_helper'

describe Bitex::JsonApi::KYC::ChileInvoicingDetailSeed do
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:read_level_key) { '742e8a9d71ef07e1a7ef9901972a82fff24e8ab2c2eb726f87dafa65768a7de11e9dc19ca9fc3efe' }
  let(:write_level_key) { 'cf35ed969e27d8434e865f673f9882c274370cff823a04b6b2acfc9e022fbb13882dd9a86f367a9b' }

  shared_examples_for 'Chile Invoicing Detail Seed' do
    it { is_expected.to be_a(described_class) }

    its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id ciudad comuna giro tax_id vat_status_code created_at updated_at]) }

    its(:ciudad) { is_expected.to eq(ciudad) }
    its(:comuna) { is_expected.to eq(comuna) }
    its(:giro) { is_expected.to eq(giro) }
    its(:tax_id) { is_expected.to eq(tax_id) }
    its(:vat_status_code) { is_expected.to eq(vat_status_code) }
  end

  describe '.create' do
    subject do
      client.chile_invoicing_detail_seeds.create(
        ciudad: ciudad,
        comuna: comuna,
        giro: giro,
        tax_id: tax_id,
        vat_status_code: vat_status_code
      )
    end

    let(:ciudad) { 'Santiago' }
    let(:comuna) { 'Chile' }
    let(:giro) { '2332' }
    let(:tax_id) { '12053214-6' }
    let(:vat_status_code) { 'consumidor_final' }

    context 'with unauthorized key', vcr: { cassette_name: 'kyc/chile_invoicing_detail_seed/create/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with unauthorized level key', vcr: { cassette_name: 'kyc/chile_invoicing_detail_seed/create/unauthorized_key' } do
      it_behaves_like 'Not enough level permissions'
    end

    context 'with authorized level key', vcr: { cassette_name: 'kyc/chile_invoicing_detail_seed/create/authorized' } do
      let(:key) { write_level_key }

      it_behaves_like 'Chile Invoicing Detail Seed'
    end
  end
end
