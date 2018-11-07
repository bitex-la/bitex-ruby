require 'spec_helper'

describe Bitex::JsonApi::CashWithdrawal do
  let(:client) { Bitex::Client.new(api_key: key) }
  let(:resource_name) { described_class.name.demodulize.underscore.pluralize }
  let(:read_level_key) { 'b47007918b1530b09bb972661c6588216a35f08e4fd9392e5c7348e0e3e4ffbd8a47ae4d22277576' }
  let(:write_level_key) { '2648e33d822a4cc51ae4ef28efed716a1ad8c37700d6b33a4295618ba880ffcf9b57e457e6594a35' }

  shared_examples_for 'Cash Withdrawal' do
    it { is_expected.to be_a(described_class) }

    its(:'attributes.keys') do
      is_expected.to contain_exactly(
        *%w[type amount fiat id status gross_amount cost fee net_amount country payment_method currency label created_at]
      )
    end
    its(:type) { is_expected.to eq(resource_name) }
  end

  describe '.create' do
    subject { client.cash_withdrawals.create(amount: amount, fiat: fiat, withdrawal_instruction_id: id, otp: otp) }

    let(:amount) { 1_000 }
    let(:fiat) { :ars }
    let(:id) { 12 }
    let(:otp) { '111111' }

    context 'with unauthorized key', vcr: { cassette_name: 'cash_withdrawals/create/unauthorized' } do
      let(:key) { :we_dont_care }

      it_behaves_like 'Not enough permissions'
    end

    context 'with unauthorized level key', vcr: { cassette_name: 'cash_withdrawals/create/unauthorized_key' } do
      it_behaves_like 'Not enough level permissions'
    end

    context 'with authorized level key' do
      let(:key) { write_level_key }

      context 'with invalid otp code', vcr: { cassette_name: 'cash_withdrawals/create/unauthorized_otp' } do
        it_behaves_like 'Not enough permissions'
      end

      context 'with non existent id', vcr: { cassette_name: 'cash_withdrawals/create/authorized_not_found' } do
        it_behaves_like 'Not Found'
      end

      context 'with existent id', vcr: { cassette_name: 'cash_withdrawals/create/authorized' } do
        it_behaves_like 'Cash Withdrawal'
      end
    end
  end
end
