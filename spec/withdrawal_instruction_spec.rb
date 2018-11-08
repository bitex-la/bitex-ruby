require 'spec_helper'

describe Bitex::JsonApi::WithdrawalInstruction do
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:read_level_key) { '81a3008a9d0b65a31d3d16759da5a7fc3c597deac1a8f23afb671e0a8d4c29aae3b92604773d5234' }
  let(:write_level_key) { '0cbb224a57d59535bb3b0c92a99e7b2ac6d36514dbd48c667ccca09961937ca93740de334568cc05' }

  shared_examples_for 'Withdrawal Instruction' do
    it { is_expected.to be_a(described_class) }

    its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type label body id schema]) }
    its(:type) { is_expected.to eq(resource_name) }
  end

  describe '.all' do
    subject { client.withdrawal_instructions.all }

    context 'with unauthorized key', vcr: { cassette_name: 'withdrawal_instructions/all/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with any level key' do
      let(:key) { read_level_key }

      context 'without previously instructions created', vcr: { cassette_name: 'withdrawal_instructions/all/authorized/empty' } do
        it { is_expected.to be_a(JsonApiClient::ResultSet) }
        it { is_expected.to be_empty }
      end

      context 'with previously instructions created', vcr: { cassette_name: 'withdrawal_instructions/all/authorized/any' } do
        it { is_expected.to be_a(JsonApiClient::ResultSet) }

        context 'taking a sample' do
          subject { super().sample }

          it_behaves_like 'Withdrawal Instruction'
        end
      end
    end
  end

  describe '.create' do
    subject { client.withdrawal_instructions.create(label: label, payment_method: method, payment_body: payment_body) }

    let(:label) { 'label' }

    let(:city) { 'Dimension C-132' }
    let(:further_instructions) { 'A further instructions' }
    let(:name) { 'Rick Sanchez' }
    let(:phone) { '1122334455' }
    let(:currency) { 'USD' }

    let(:shared_body_fields) do
      {
        'city' => city,
        'country' => country,
        'currency' => currency,
        'further_instructions' => further_instructions,
        'name' => name,
        'payment_method' => method,
        'phone' => phone
      }
    end

    let(:payment_body) { body.merge(shared_body_fields) }

    context 'with unauthorized key', vcr: { cassette_name: 'withdrawal_instructions/create/unauthorized' } do
      let(:method) { 'domestic_bank' }
      let(:country) { :dont_care }
      let(:body) do
        {
          'account_type' => :dont_care,
          'address' => :dont_care,
          'bank' => :dont_care,
          'bank_account_number' => :dont_care,
          'cbu' => :dont_care,
          'cuit' => :dont_care,
          'currency' => :dont_care
        }
      end

      it_behaves_like 'Not enough permissions'
    end

    context 'with authorized key' do
      let(:key) { write_level_key }

      shared_examples_for 'New Withdrawal Instruction' do
        it_behaves_like 'Withdrawal Instruction'

        its(:label) { is_expected.to eq(label) }
        its(:body) { is_expected.to eq(body.merge(shared_body_fields)) }
      end

      context 'with domestic bank', vcr: { cassette_name: 'withdrawal_instructions/create/domestic_bank' } do
        let(:method) { 'domestic_bank' }
        let(:country) { 'AR' }
        let(:body) do
          {
           'account_type' => 'savings',
           'address' => 'a address',
           'bank' => 'hsbc',
           'bank_account_number' => '12345678',
           'cbu' => '1234567812345678',
           'cuit' => '20112233344552'
          }
        end

        it_behaves_like 'New Withdrawal Instruction'
      end

      context 'with international bank', vcr: { cassette_name: 'withdrawal_instructions/create/international_bank' } do
        let(:method) { 'international_bank' }
        let(:country) { 'CL' }
        let(:body) do
          {
           'account_type' => 'savings',
           'address' => 'a address',
           'bank' => 'bco_chile',
           'bank_account_number' => '12345678',
           'bank_address' => 'a bank address',
           'bank_city' => 'a bank city',
           'bank_country' => 'CL',
           'bank_postal_code' => 'AABBCC',
           'bank_swift' => 'BANKUS66',
           'postal_code' => 'XXYYZZ'
          }
        end

        it_behaves_like 'New Withdrawal Instruction'
      end

      context 'with third party', vcr: { cassette_name: 'withdrawal_instructions/create/third_party' } do
        let(:method) { 'third_party' }
        let(:country) { 'PY' }
        let(:body) { {} }

        it_behaves_like 'New Withdrawal Instruction'
      end
    end
  end

  describe '.destroy' do
    subject { client.withdrawal_instructions.new(id: id).destroy }

    let(:id) { 13 }

    context 'with unauthorized key', vcr: { cassette_name: 'withdrawal_instructions/destroy/unauthorized' } do
      it_behaves_like 'Not enough permissions'
    end

    context 'with unauthorized level key', vcr: { cassette_name: 'withdrawal_instructions/destroy/unauthorized_key' } do
      it_behaves_like 'Not enough level permissions'
    end

    context 'with authorized level key' do
      let(:key) { write_level_key }

      context 'with non-existent id', vcr: { cassette_name: 'withdrawal_instructions/destroy/non_existent_id' } do
        it_behaves_like 'Not Found'
      end

      context 'with existent id', vcr: { cassette_name: 'withdrawal_instructions/destroy/authorized' } do
        it { is_expected.to be_truthy }
      end
    end
  end

  describe '.valid_payment?' do
    before(:each) do
      described_class.stub(valid_method?: method_result)
      described_class.stub(valid_body?: body_result)
    end

    subject { described_class.send(:valid_payment?, :we_dont_care_method, { we_dont_care: :body}) }

    context 'valid method' do
      let(:method_result) { true }

      context 'invalid body' do
        let(:body_result) { false }

        it { is_expected.to be_falsey }
      end

      context 'valid body' do
        let(:body_result) { true }

        it { is_expected.to be_truthy }
      end
    end

    context 'valid body' do
      let(:body_result) { true }

      context 'invalid method' do
        let(:method_result) { false }

        it { is_expected.to be_falsey }
      end

      context 'valid method' do
        let(:method_result) { true }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '.valid_method?' do
    subject { described_class.send(:valid_method?, method) }

    context 'with invalid method' do
      let(:method) { :we_dont_care }

      it { is_expected.to be_falsey }
    end

    context 'with valid method' do
      let(:method) { %w[domestic_bank international_bank third_party].sample }

      it { is_expected.to be_truthy }
    end
  end

  describe '.valid_body?' do
    subject { described_class.send(:valid_body?, payment_method, payment_body_keys) }

    context 'with invalid payment method' do
      let(:payment_method) { :we_dont_care }
      let(:payment_body_keys) { {} }

      it { expect { subject }.to raise_error(NoMethodError) }
    end
  end

  describe '.domestic_bank_body' do
    subject { described_class.send(:domestic_bank_body) }

    it do
      is_expected.to contain_exactly(
        *%w[name city further_instructions phone account_type address bank bank_account_number cbu country cuit currency]
      )
    end
  end

  describe '.international_bank_body' do
    subject { described_class.send(:international_bank_body) }

    it do
      is_expected.to contain_exactly(
        *%w[name city further_instructions phone account_type address bank bank_account_number bank_address bank_city
        bank_country bank_postal_code bank_swift postal_code]
      )
    end
  end

  describe '.third_party_body' do
    subject { described_class.send(:third_party_body) }

    it { is_expected.to contain_exactly(*%w[name city further_instructions phone]) }
  end

  describe '.shared_body_bank' do
    subject { described_class.send(:shared_body_bank) }

    it { is_expected.to contain_exactly(*%w[name city further_instructions phone account_type address bank bank_account_number]) }
  end

  describe '.shared_body' do
    subject { described_class.send(:shared_body) }

    it { is_expected.to contain_exactly(*%w[name city further_instructions phone]) }
  end
end
