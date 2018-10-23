shared_examples_for 'OrderGroup' do
  it { is_expected.to be_a(described_class) }

  its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id amount remaining_amount price status]) }
  its(:type) { is_expected.to eq(resource_name) }
end

shared_examples_for 'Invalid orderbook code' do
  let(:key) { :we_dont_care }
  let(:orderbook_code) { invalid_orderbook_code }
  let(:order_id) { :we_dont_care }

  it { expect { subject }.to raise_exception(Bitex::UnknownOrderbook) }
end

shared_examples_for 'Non existent OrderGroup' do
  let(:order_id) { '99' }

  it { expect { subject }.to raise_exception(JsonApiClient::Errors::NotFound) }
end

shared_examples_for 'Not enough permissions' do
  let(:key) { read_level_key }
  let(:order_id) { '22' }

  it { expect { subject }.to raise_exception(JsonApiClient::Errors::NotAuthorized) }
end

shared_examples_for 'Cancelling OrderGroup' do
  it { is_expected.to be_an(Array) }
  it { is_expected.to be_empty }
end

shared_examples_for 'New order with zero amount' do
  let(:amount) { 0 }

  it { expect { subject }.to raise_exception(Bitex::InvalidArgument) }
end

shared_examples_for 'Very small order' do
  let(:amount) { 0.00_000_001 }

  it { expect { subject }.to raise_exception(Bitex::OrderNotPlaced).with_message('La orden es muy pequeña') }
end

shared_examples_for 'Not enough funds' do
  let(:amount) { 12_000_000 }

  it_behaves_like 'OrderGroup'

  its(:amount) { is_expected.to eq(amount) }
  its(:price) { is_expected.to eq(price) }
  its(:status) { is_expected.to eq('cancelled') }
end

shared_examples_for 'Successful new order' do
  it_behaves_like 'OrderGroup'

  its(:amount) { is_expected.to eq(amount) }
  its(:price) { is_expected.to eq(price) }
  its(:status) { is_expected.to eq('executing') }
end
