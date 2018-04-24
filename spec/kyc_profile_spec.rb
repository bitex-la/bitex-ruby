require 'spec_helper'

describe Bitex::KycProfile do
  before(:each) { Bitex.api_key = 'valid_api_key' }

  let(:id) { 1 }
  let(:first_name) { 'Billy' }
  let(:last_name) { 'Bob' }
  let(:personal_id_number) { '33222111N' }
  let(:personal_id_issuer) { 'AR' }
  let(:personal_id_type) { :passport }
  let(:tax_id) { 4_332_221_115 }
  let(:birth_date) { Time.at(946_685_400).utc }
  let(:rest_birth_date) { '2000/01/01' }
  let(:nationality) { 'brazilian' }
  let(:gender) { :male }
  let(:occupation) { 'Singer' }
  let(:home_address) { 'Argentina, Buenos Aires, etc' }
  let(:work_address) { 'Argentina, La Plata' }
  let(:phone_numbers) { '+51 555 120921' }
  let(:legal_entity) { true }
  let(:politically_exposed_person) { true }
  let(:usage_tier) { :micro }
  let(:accepted_usage_tier) { :micro }

  let(:kyc_profile_params) do
    {
      first_name: first_name, last_name: last_name, personal_id_number: personal_id_number,
      personal_id_issuer: personal_id_issuer, personal_id_type: personal_id_type, tax_id: tax_id, birth_date: birth_date,
      nationality: nationality, gender: gender, occupation: occupation, home_address: home_address, work_address: work_address,
      phone_numbers: phone_numbers, legal_entity: legal_entity, politically_exposed_person: politically_exposed_person,
      usage_tier: usage_tier
    }
  end

  let(:as_json) do
    [id, first_name, last_name, personal_id_number, personal_id_issuer, personal_id_type, tax_id, birth_date, nationality,
     gender, occupation, home_address, work_address, phone_numbers, legal_entity, politically_exposed_person, usage_tier,
     accepted_usage_tier]
  end

  let(:kyc_profile) { Bitex::KycProfile.from_json(as_json) }

  context 'deserializing from json' do
    it 'sets first name as String' do
      kyc_profile.first_name.should be_an String
      kyc_profile.first_name.should eq first_name
    end

    it 'sets last name as String' do
      kyc_profile.last_name.should be_an String
      kyc_profile.last_name.should eq last_name
    end

    it 'sets personal ID number as String' do
      kyc_profile.personal_id_number.should be_an String
      kyc_profile.personal_id_number.should eq personal_id_number
    end

    it 'sets personal ID issuer as String' do
      kyc_profile.personal_id_issuer.should be_an String
      kyc_profile.personal_id_issuer.should eq personal_id_issuer
    end

    it 'sets personal ID type as Symbol' do
      kyc_profile.personal_id_type.should be_an Symbol
      kyc_profile.personal_id_type.should eq personal_id_type
    end

    it 'sets tax ID as Integer' do
      kyc_profile.tax_id.should be_an Integer
      kyc_profile.tax_id.should eq tax_id
    end

    it 'sets birth date as Time' do
      kyc_profile.birth_date.should be_an Time
      kyc_profile.birth_date.should eq birth_date
    end

    it 'can have a nil birth_date' do
      as_json[7] = nil

      kyc_profile.birth_date.should be_nil
    end

    it 'sets nationality as String' do
      kyc_profile.nationality.should be_an String
      kyc_profile.nationality.should eq nationality
    end

    it 'sets gender as Symbol' do
      kyc_profile.gender.should be_an Symbol
      kyc_profile.gender.should be gender
    end

    it 'sets occupation as String' do
      kyc_profile.occupation.should be_an String
      kyc_profile.occupation.should eq occupation
    end

    it 'sets home address as String' do
      kyc_profile.home_address.should be_an String
      kyc_profile.home_address.should eq home_address
    end

    it 'sets work address as String' do
      kyc_profile.work_address.should be_an String
      kyc_profile.work_address.should eq work_address
    end

    it 'sets phone numbers as String' do
      kyc_profile.phone_numbers.should be_an String
      kyc_profile.phone_numbers.should eq phone_numbers
    end

    it 'sets legal entity as Boolean' do
      kyc_profile.legal_entity.should be_an TrueClass
      kyc_profile.legal_entity.should eq legal_entity
    end

    it 'sets politically exposed person as Boolean' do
      kyc_profile.politically_exposed_person.should be_an TrueClass
      kyc_profile.politically_exposed_person.should eq politically_exposed_person
    end

    it 'sets usage tier as Symbol' do
      kyc_profile.usage_tier.should be_an Symbol
      kyc_profile.usage_tier.should eq usage_tier
    end

    it 'sets accepted usage tier as Symbol' do
      kyc_profile.accepted_usage_tier.should be_an Symbol
      kyc_profile.accepted_usage_tier.should eq accepted_usage_tier
    end
  end

  it 'creates a new kyc profile' do
    stub_private(:post, '/private/kyc_profiles', :kyc_profile, kyc_profile_params.merge(birth_date: rest_birth_date))

    Bitex::KycProfile.create!(kyc_profile_params).should be_a Bitex::KycProfile
  end

  it 'finds a single kyc profile' do
    stub_private(:get, "/private/kyc_profiles/#{id}", :kyc_profile)

    kyc_profile = Bitex::KycProfile.find(id)

    kyc_profile.should be_a Bitex::KycProfile
    kyc_profile.id.should eq id
  end

  it 'updates a kyc profile' do
    stub_private(:put, "/private/kyc_profiles/#{id}", :kyc_profile, kyc_profile_params.merge(birth_date: rest_birth_date))

    kyc_profile.update!(kyc_profile_params)
    kyc_profile.birth_date.should eq birth_date
  end

  it 'lists all kyc profiles' do
    stub_private(:get, '/private/kyc_profiles', :kyc_profiles)

    kyc_profiles = Bitex::KycProfile.all

    kyc_profiles.should be_an Array
    kyc_profiles.first.should be_an Bitex::KycProfile
  end

  it 'creates a kyc file' do
    path = File.expand_path('fixtures/file.jpg', __dir__)
    stub_private(:post, "/private/kyc_profiles/#{id}/kyc_files", :kyc_file, document: path, document_content_type: 'image/jpg')

    kyc_profile.add_kyc_file!(path, 'image/jpg') { |kyc_file| kyc_file.should be_a Bitex::KycFile }
  end

  it 'creates a kyc file without specifying content type' do
    path = File.expand_path('fixtures/file.jpg', __dir__)
    stub_private(:post, '/private/kyc_profiles/1/kyc_files', :kyc_file, document: path)

    kyc_profile.add_kyc_file!(path) { |kyc_file| kyc_file.should be_a Bitex::KycFile }
  end

  it 'lists a profiles kyc files' do
    stub_private(:get, "/private/kyc_profiles/#{id}/kyc_files", :kyc_files)

    kyc_profile.kyc_files do |kyc_files|
      kyc_files.should be_an Array
      kyc_files.any.should be_a Bitex::KycFile
    end
  end
end
