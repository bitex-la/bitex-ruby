module Bitex
  ##
  # Documentation here!
  #
  class KycProfile
    # @!attribute id
    #   @return [Integer] This KycProfile's unique ID.
    attr_accessor :id

    # @!attribute first_name
    #   @return [String] Name.
    attr_accessor :first_name

    # @!attribute last_name
    #   @return [String] Last Name.
    attr_accessor :last_name

    # @!attribute personal_id_number
    #   @return [String] Personal ID Number.
    attr_accessor :personal_id_number

    # @!attribute personal_id_issuer
    #   @return [String] ISO country code for the issuer of this ID.
    attr_accessor :personal_id_issuer

    # @!attribute personal_id_type
    #   @return [symbol] Type of ID. [:passport]
    attr_accessor :personal_id_type

    # @!attribute tax_id
    #   @return [Intger] Tax ID.
    attr_accessor :tax_id

    # @!attribute birth_date
    #   @return [Time] Birth date.
    attr_accessor :birth_date

    # @!attribute nationality
    #   @return [String] Nationality.
    attr_accessor :nationality

    # @!attribute gender
    #   @return [Symbol] Gender.
    attr_accessor :gender

    # @!attribute occupation
    #   @return [String]
    attr_accessor :occupation

    # @!attribute home_address
    #   @return [String] Home address.
    attr_accessor :home_address

    # @!attribute work_address
    #   @return [String] Work address.
    attr_accessor :work_address

    # @!attribute phone_numbers
    #   @return [String] Phone numbers.
    attr_accessor :phone_numbers

    # @!attribute legal_entity
    #   @return [Boolean] Is legal entity.
    attr_accessor :legal_entity

    # @!attribute politically_exposed_person
    #   @return [Boolean] Is politically exposed.
    attr_accessor :politically_exposed_person

    # @!attribute usage_tier
    #   @return [Symbol] Requested usage tier.
    attr_accessor :usage_tier

    # @!attribute accepted_usage_tier
    #   @return [Symbol] Current usage tier as accepted by our compliance officers.
    attr_accessor :accepted_usage_tier

    # @visibility private
    # rubocop:disable Metrics/AbcSize
    def self.from_json(json)
      new.tap do |profile|
        profile.id = json[0]
        profile.first_name = json[1]
        profile.last_name = json[2]
        profile.personal_id_number = json[3]
        profile.personal_id_issuer = json[4]
        profile.personal_id_type = json[5].to_sym
        profile.tax_id = json[6]
        profile.birth_date = json[7] ? Time.at(json[7]) : nil
        profile.nationality = json[8]
        profile.gender = json[9].to_sym
        profile.occupation = json[10]
        profile.home_address = json[11]
        profile.work_address = json[12]
        profile.phone_numbers = json[13]
        profile.legal_entity = json[14]
        profile.politically_exposed_person = json[15]
        profile.usage_tier = json[16].to_sym
        profile.accepted_usage_tier = json[17].to_sym
      end
    end
    # rubocop:enable Metrics/AbcSize

    def self.create!(params)
      from_json(Api.private(:post, '/private/kyc_profiles', sanitize(params)))
    end

    def self.find(id)
      from_json(Api.private(:get, "/private/kyc_profiles/#{id}"))
    end

    def self.all
      Api.private(:get, '/private/kyc_profiles').map { |kyc| from_json(kyc) }
    end

    def self.sanitize(params)
      params.merge(birth_date: params[:birth_date].strftime('%Y/%m/%d'))
    end

    def update!(params)
      self.class.from_json(Api.private(:put, "/private/kyc_profiles/#{id}", self.class.sanitize(params)))
    end

    def add_kyc_file!(path, content_type = nil)
      response = Api.private(
        :post,
        "/private/kyc_profiles/#{id}/kyc_files",
        { document_content_type: content_type },
        document: path
      )

      KycFile.from_json(response)
    end

    def kyc_files
      Api.private(:get, "/private/kyc_profiles/#{id}/kyc_files").map { |kyc| KycFile.from_json(kyc) }
    end
  end
end
