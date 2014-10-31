require 'spec_helper'

describe Bitex::KycProfile do
  before :each do 
    Bitex.api_key = 'valid_api_key'
  end

  let(:params_for_create_or_update) do
    { first_name: 'Billy',
      last_name: 'Bob',
      personal_id_number: '33222111N',
      personal_id_issuer: 'AR',
      personal_id_type: 'passport',
      tax_id: '4332221115',
      birth_date: Time.at(946685400),
      nationality: 'brazilian',
      gender: 'male',
      occupation: 'Singer',
      home_address: 'Argentina, Buenos Aires, etc',
      work_address: 'Argentina, La Plata',
      phone_numbers: '+51 555 120921',
      legal_entity: true,
      politically_exposed_person: true,
      usage_tier: 'micro'
    }
  end
  
  let(:rest_params_for_create_or_update) do
    { first_name: 'Billy',
      last_name: 'Bob',
      personal_id_number: '33222111N',
      personal_id_issuer: 'AR',
      personal_id_type: 'passport',
      tax_id: '4332221115',
      birth_date: '1999/12/31',
      nationality: 'brazilian',
      gender: 'male',
      occupation: 'Singer',
      home_address: 'Argentina, Buenos Aires, etc',
      work_address: 'Argentina, La Plata',
      phone_numbers: '+51 555 120921',
      legal_entity: true,
      politically_exposed_person: true,
      usage_tier: 'micro',
    }
  end

  let(:as_json) do
    [           1,   # Kyc Profile id.
                 'Billy',   # Name
                   'Bob',   # Last Name.
             '33222111N',   # Personal ID Number
                    'AR',   # ISO country code for the issuer of this ID.
              'passport',   # Type of ID
            '4332221115',   # Tax Id
               946685400,   # Birth date as unix timestamp.
             'brazilian',   # Nationality
                  'male',   # Gender
                'Singer',   # Occupation
     'Argentina, Buenos Aires, etc',   # Home address.
     'Argentina, La Plata',   # Work address.
        '+51 555 120921',   # Phone numbers.
                    true,   # Is legal entity.
                    true,   # Is politically exposed.
                 'micro',   # Requested usage tier.
                 'micro',   # Current usage tier as accepted by
                            # our compliance officers.
    ]
  end

  { id: 1,
    first_name: 'Billy',
    last_name: 'Bob',
    personal_id_number: '33222111N',
    personal_id_issuer: 'AR',
    personal_id_type: 'passport',
    tax_id: '4332221115',
    birth_date: Time.at(946685400),
    nationality: 'brazilian',
    gender: 'male',
    occupation: 'Singer',
    home_address: 'Argentina, Buenos Aires, etc',
    work_address: 'Argentina, La Plata',
    phone_numbers: '+51 555 120921',
    legal_entity: true,
    politically_exposed_person: true,
    usage_tier: 'micro',
    accepted_usage_tier: 'micro',
  }.each do |field, value|
    it "sets #{field}" do
      subject.class.from_json(as_json).send(field).should == value
    end
  end

  it 'creates a new kyc profile' do
    stub_private(:post, "/private/kyc_profiles", 'kyc_profile',
      rest_params_for_create_or_update)
    Bitex::KycProfile.create!(params_for_create_or_update)
      .should be_a Bitex::KycProfile
  end
  
  it 'finds a single kyc profile' do
    stub_private(:get, '/private/kyc_profiles/1', 'kyc_profile')
    kyc_profile = Bitex::KycProfile.find(1)
    kyc_profile.should be_a Bitex::KycProfile
  end
  
  it 'lists all kyc profiles' do
    stub_private(:get, '/private/kyc_profiles', 'kyc_profiles')
    kyc_profiles = Bitex::KycProfile.all
    kyc_profiles.should be_an Array
    kyc_profiles.first.should be_an Bitex::KycProfile
  end

  it 'updates a kyc profile' do
    stub_private(:put, "/private/kyc_profiles/1", 'kyc_profile',
      rest_params_for_create_or_update)
    kyc_profile = Bitex::KycProfile.from_json(as_json)
    kyc_profile.update!(params_for_create_or_update)
  end

  it 'creates a kyc file' do
    path =  File.expand_path('../fixtures/file.jpg', __FILE__)
    stub_private(:post, '/private/kyc_profiles/1/kyc_files', 'kyc_file',
     {document: path, document_content_type: 'image/jpg'})
    kyc_profile = Bitex::KycProfile.from_json(as_json)
    kyc_file = kyc_profile.add_kyc_file!(path, 'image/jpg')
    kyc_file.should be_a Bitex::KycFile
  end

  it 'creates a kyc file without specifying content type' do
    path =  File.expand_path('../fixtures/file.jpg', __FILE__)
    stub_private(:post, '/private/kyc_profiles/1/kyc_files', 'kyc_file',
     {document: path})
    kyc_profile = Bitex::KycProfile.from_json(as_json)
    kyc_file = kyc_profile.add_kyc_file!(path)
    kyc_file.should be_a Bitex::KycFile
  end
  
  it 'lists a profiles kyc files' do
    stub_private(:get, '/private/kyc_profiles/1/kyc_files', 'kyc_files')
    kyc_profile = Bitex::KycProfile.from_json(as_json)
    kyc_files = kyc_profile.kyc_files
    kyc_files.should be_an Array
    kyc_files.first.should be_a Bitex::KycFile
  end
  
  it 'can have a nil birth_date' do
    json = as_json.dup
    json[7] = nil
    kyc_profile = Bitex::KycProfile.from_json(json)
    kyc_profile.birth_date.should be_nil
  end
end
