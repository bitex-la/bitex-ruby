module Bitex
  class KycFile
    attr_accessor :id, :kyc_profile_id, :url, :file_name,
      :content_type, :file_size

    def self.from_json(json)
      t = new
      t.id, t.kyc_profile_id, t.url, t.file_name, t.content_type, t.file_size =
        json
      t
    end
    
    def self.all
      Api.private(:get, "/private/kyc_files").collect{|x| from_json(x) }
    end
  end
end

