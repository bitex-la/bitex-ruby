require 'spec_helper'

describe Bitex::KycFile do
  before(:each) { Bitex.api_key = 'valid_api_key' }

  let(:id) { 1 }
  let(:kyc_profile_id) { 2 }
  let(:url) { 'http://foo.bar.example/photo.jpg' }
  let(:file_name) { 'photo.jpg' }
  let(:file_size) { 10_000 }
  let(:content_type) { 'application/jpeg' }

  let(:as_json) { [id, kyc_profile_id, url, file_name, content_type, file_size] }
  let(:kyc_file) { subject.class.from_json(as_json)  }
  let(:kyc_files) { Bitex::KycFile.all }

  context 'deserializing from json' do
    it 'sets url as String' do
      kyc_file.url.should be_an String
      kyc_file.url.should eq url
    end

    it 'sets file name as String' do
      kyc_file.file_name.should be_an String
      kyc_file.file_name.should eq file_name
    end

    it 'sets file size as Integer' do
      kyc_file.file_size.should be_an Integer
      kyc_file.file_size.should eq file_size
    end

    it 'sets content type as String' do
      kyc_file.content_type.should be_an String
      kyc_file.content_type.should eq content_type
    end
  end

  it 'lists all kyc profiles' do
    stub_private(:get, '/private/kyc_files', :kyc_files)

    kyc_files.should be_an Array
    kyc_files.sample.should be_an Bitex::KycFile
    kyc_files.find(id: id).should be_present
  end
end
