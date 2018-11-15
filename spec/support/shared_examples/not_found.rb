shared_examples_for 'Not Found' do
  let(:id) { 99 }

  it { expect { subject }.to raise_exception(JsonApiClient::Errors::NotFound) }
end
