require 'spec_helper'

describe Bitex::JsonApi::KYC::NaturalDocketSeed do
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:read_level_key) { '742e8a9d71ef07e1a7ef9901972a82fff24e8ab2c2eb726f87dafa65768a7de11e9dc19ca9fc3efe' }
  let(:write_level_key) { 'cf35ed969e27d8434e865f673f9882c274370cff823a04b6b2acfc9e022fbb13882dd9a86f367a9b' }

  shared_examples_for 'Natural Docket Seed' do
    it { is_expected.to be_a(described_class) }

    its(:'attributes.keys') do
      is_expected.to contain_exactly(
        *%w[type id first_name last_name nationality gender_code marital_status_code politically_exposed birth_date job_title
        job_description politically_exposed_reason created_at updated_at]
      )
    end

    its(:first_name) { is_expected.to eq(first_name) }
    its(:last_name) { is_expected.to eq(last_name) }
    its(:nationality) { is_expected.to eq(nationality) }
    its(:gender_code) { is_expected.to eq(gender_code) }
    its(:gender_code) { is_expected.to eq(gender_code) }
    its(:marital_status_code) { is_expected.to eq(marital_status_code) }
    its(:politically_exposed) { is_expected.to eq(politically_exposed) }
    its(:birth_date) { is_expected.to eq(birth_date) }

    its(:job_title) { is_expected.to eq(job_title) }
    its(:job_description) { is_expected.to eq(job_description) }
    its(:politically_exposed_reason) { is_expected.to eq(politically_exposed_reason) }
  end

  describe '.create' do
    subject do
      client.natural_docket_seeds.create(
        first_name: first_name,
        last_name: last_name,
        nationality: nationality,
        gender_code: gender_code,
        marital_status_code: marital_status_code,
        politically_exposed: politically_exposed,
        birth_date: birth_date,
        job_title: job_title,
        job_description: job_description,
        politically_exposed_reason: politically_exposed_reason
      )
    end

    let(:first_name) { 'Rick' }
    let(:last_name) { 'Sanchez' }
    let(:nationality) { 'AR' }
    let(:gender_code) { 'male' }
    let(:marital_status_code) { 'single' }
    let(:politically_exposed) { false }
    let(:birth_date) { '1989-05-17' }

    let(:job_title) { 'scientific' }
    let(:job_description) { 'science, absolute reality' }
    let(:politically_exposed_reason) { 'I´m a rockstar' }

    context 'with unauthorized key', vcr: { cassette_name: 'kyc/natural_docket_seeds/create/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with unauthorized level key', vcr: { cassette_name: 'kyc/natural_docket_seeds/create/unauthorized_key' } do
      it_behaves_like 'Not enough level permissions'
    end

    context 'with authorized level key', vcr: { cassette_name: 'kyc/natural_docket_seeds/create/authorized' } do
      let(:key) { write_level_key }

      it_behaves_like 'Natural Docket Seed'
    end
  end
end
