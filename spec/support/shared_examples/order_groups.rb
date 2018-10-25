shared_examples_for '.resource_type' do |resource_type|
  subject { described_class.resource_type }

  it { is_expected.to eq(resource_type) }
end

shared_examples_for '.valid_amount?' do
  subject { described_class.send(:valid_amount?, amount) }

  context 'with a negative amount' do
    let(:amount) { -1 }

    it { is_expected.to be_falsey }
  end

  context 'with zero amount' do
    let(:amount) { 0 }

    it { is_expected.to be_falsey }
  end

  context 'with a positive amount' do
    let(:amount) { 1 }

    it { is_expected.to be_truthy }
  end
end

shared_examples_for '.json_api_body_parser' do |resource_type|
  subject { described_class.send(:json_api_body_parser, ids) }

  let(:ids) { (1..10).to_a }

  it { is_expected.to be_an(Array) }
  its(:size) { is_expected.to eq(ids.size) }
end

shared_examples_for '.to_json_api_body' do |resource_type|
  subject { described_class.send(:to_json_api_body, id) }

  let(:id) { rand(10) }

  it { is_expected.to be_a(Hash) }

  its(:keys) { is_expected.to include(:data) }
  its(%i[data id]) { is_expected.to eq(id) }
  its(%i[data type]) { is_expected.to eq(resource_type) }
end
