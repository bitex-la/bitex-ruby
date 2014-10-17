module Bitex
  class KycProfile

    attr_accessor :id, :first_name, :last_name, :personal_id_number,
      :personal_id_issuer, :personal_id_type, :tax_id, :birth_date,
      :nationality, :gender, :occupation, :home_address, :work_address,
      :phone_numbers, :legal_entity, :politically_exposed_person,
      :usage_tier, :accepted_usage_tier

    # @visibility private
    def self.from_json(json)
      new.tap do |thing|
        thing.id = json[0]
        thing.first_name = json[1]
        thing.last_name = json[2]
        thing.personal_id_number = json[3]
        thing.personal_id_issuer = json[4]
        thing.personal_id_type = json[5]
        thing.tax_id = json[6]
        thing.birth_date = json[7] ? Time.at(json[7]) : nil
        thing.nationality = json[8]
        thing.gender = json[9]
        thing.occupation = json[10]
        thing.home_address = json[11]
        thing.work_address = json[12]
        thing.phone_numbers = json[13]
        thing.legal_entity = json[14]
        thing.politically_exposed_person = json[15]
        thing.usage_tier = json[16]
        thing.accepted_usage_tier = json[17]
      end
    end

    def self.create!(params)
      params = params.dup
        .merge(birth_date: params[:birth_date].strftime('%Y/%m/%d'))
      from_json(Api.private(:post, "/private/kyc_profiles", params))
    end

    def self.find(id)
      from_json(Api.private(:get, "/private/kyc_profiles/#{id}"))
    end

    def self.all
      Api.private(:get, "/private/kyc_profiles").collect{|x| from_json(x) }
    end

    def update!(params)
      params = params.dup
        .merge(birth_date: params[:birth_date].strftime('%Y/%m/%d'))
      self.class.from_json(Api.private(:put, "/private/kyc_profiles/#{id}", params))
    end
    
    def add_kyc_file!(path)
      response = Api.private(:post, "/private/kyc_profiles/#{id}/kyc_files",
        {}, {document: path})
      KycFile.from_json(response)
    end
  
    def kyc_files
      Api.private(:get, "/private/kyc_profiles/#{id}/kyc_files")
        .collect{|x| KycFile.from_json(x)}
    end
  end
end

