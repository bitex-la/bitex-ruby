shared_examples_for 'Invalid orderbook code' do
  let(:key) { :we_dont_care }
  let(:orderbook_code) { :invalid_orderbook_code }
  let(:id) { :we_dont_care }

  it { expect { subject }.to raise_exception(Bitex::UnknownOrderbook) }
end

shared_examples_for '.valid_code?' do
  subject { described_class.send(:valid_code?, orderbook_code) }

  context 'with a valid orderbook code' do
    let(:orderbook_code) { valid_orderbook_code }

    it { is_expected.to be_truthy }
  end

  context 'with a invalid orderbook code' do
    let(:orderbook_code) { invalid_orderbook_code }

    it { is_expected.to be_falsey }
  end
end
