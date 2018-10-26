shared_examples_for 'Order' do
  it { is_expected.to be_a(described_class) }

  its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id amount remaining_amount price status]) }
  its(:type) { is_expected.to eq(resource_name) }
end

shared_examples_for 'Cancelling order' do
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

  it_behaves_like 'Order'

  its(:amount) { is_expected.to eq(amount) }
  its(:price) { is_expected.to eq(price) }
  its(:status) { is_expected.to eq('cancelled') }
end

shared_examples_for 'Successful new order' do
  it_behaves_like 'Order'

  its(:amount) { is_expected.to eq(amount) }
  its(:price) { is_expected.to eq(price) }
  its(:status) { is_expected.to eq('executing') }
end
