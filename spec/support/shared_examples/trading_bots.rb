shared_examples_for 'Trading Bot' do
  it { is_expected.to be_a(described_class) }

  its(:'attributes.keys') { is_expected.to contain_exactly(*%w[type id amount remaining_amount chunk_size eta executing to_cancel]) }
  its(:type) { is_expected.to eq(resource_name) }
end

shared_examples_for 'Trading Bot Orderbook' do
  its([:id]) { is_expected.to eq(orderbook_id) }
  its([:type]) { is_expected.to eq('orderbooks') }
end

shared_examples_for 'Cancelling bot' do
  its(:executing) { is_expected.to be_truthy }
  its(:to_cancel) { is_expected.to be_truthy }
end
