require 'spec_helper'

describe Bitex::KycFile do
  before :each do 
    Bitex.api_key = 'valid_api_key'
  end

  let(:as_json) do
    [1,2,'http://foo.bar.example/photo.jpg', 'photo.jpg', 'application/jpeg', 10000]
  end

  { id: 1,
    kyc_profile_id: 2,
    url:'http://foo.bar.example/photo.jpg',
    file_name: 'photo.jpg',
    content_type: 'application/jpeg',
    file_size: 10000
  }.each do |field, value|
    it "sets #{field}" do
      subject.class.from_json(as_json).send(field).should == value
    end
  end

  it 'lists all kyc profiles' do
    stub_private(:get, '/private/kyc_files', 'kyc_files')
    kyc_files = Bitex::KycFile.all
    kyc_files.should be_an Array
    kyc_files.first.should be_an Bitex::KycFile
  end
end
