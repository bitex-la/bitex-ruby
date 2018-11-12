require 'spec_helper'

describe Bitex::JsonApi::KYC::PhoneSeed do
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:read_level_key) { '742e8a9d71ef07e1a7ef9901972a82fff24e8ab2c2eb726f87dafa65768a7de11e9dc19ca9fc3efe' }
  let(:write_level_key) { 'cf35ed969e27d8434e865f673f9882c274370cff823a04b6b2acfc9e022fbb13882dd9a86f367a9b' }

  shared_examples_for 'Phone Seed' do
    it { is_expected.to be_a(described_class) }

    its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id country number phone_kind_code has_telegram has_whatsapp note created_at updated_at]) }

    its(:country) { is_expected.to eq(country) }
    its(:number) { is_expected.to eq(number) }
    its(:phone_kind_code) { is_expected.to eq(phone_kind_code) }
    its(:has_telegram) { is_expected.to eq(has_telegram) }
    its(:has_whatsapp) { is_expected.to eq(has_whatsapp) }
    its(:note) { is_expected.to eq(note) }
  end

  describe '.create' do
    subject do
      client.phone_seeds.create(
        country: country,
        number: number,
        phone_kind_code: phone_kind_code,
        has_telegram: has_telegram,
        has_whatsapp: has_whatsapp,
        note: note
      )
    end

    let(:country) { 'AR' }
    let(:number) { '1234567890' }
    let(:phone_kind_code) { 'main' }
    let(:has_telegram) { true }
    let(:has_whatsapp) { false }
    let(:note) do
      'It´s a figure of speech, Morty! They´re bureaucrats! '\
        'I don´t respect them. Just keep shooting, Morty! '\
        'You have no idea what prison is like here!'
    end

    context 'with unauthorized key', vcr: { cassette_name: 'kyc/phone_seed/create/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with unauthorized level key', vcr: { cassette_name: 'kyc/phone_seed/create/unauthorized_key' } do
      it_behaves_like 'Not enough level permissions'
    end

    context 'with authorized level key', vcr: { cassette_name: 'kyc/phone_seed/create/authorized' } do
      let(:key) { write_level_key }

      it_behaves_like 'Phone Seed'
    end
  end
end
