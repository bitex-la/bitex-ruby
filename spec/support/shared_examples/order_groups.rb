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

  it { expect { subject }.to raise_exception(JsonApiClient::Errors::NotAuthorized) }
end

shared_examples_for 'Cancelling OrderGroup' do
  it { is_expected.to be_an(Array) }
  it { is_expected.to be_empty }
end
