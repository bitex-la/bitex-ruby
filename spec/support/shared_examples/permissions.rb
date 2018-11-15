shared_examples_for 'Not enough permissions' do
  let(:key) { 'we_dont_care' }

  it { expect { subject }.to raise_exception(JsonApiClient::Errors::NotAuthorized) }
end

shared_examples_for 'Not enough level permissions' do
  let(:key) { read_level_key }

  it { expect { subject }.to raise_exception(JsonApiClient::Errors::NotAuthorized) }
end
