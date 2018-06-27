module Bitex
  ##
  # Documentation here!
  #
  class KycFile
    # @!attribute id
    #   @return [Integer] This KycFile's unique ID.
    attr_accessor :id

    # @!attribute id
    #   @return [Integer] This KycProfile's unique ID.
    attr_accessor :kyc_profile_id

    # @!attribute url
    #   @return [String] url to photo file.
    attr_accessor :url

    # @!attribute file_name
    #   @return [String] file name.
    attr_accessor :file_name

    # @!attribute file_size
    #   @return [Integer] file size.
    attr_accessor :file_size

    # @!attribute content_type
    #   @return [String] Content type.
    attr_accessor :content_type

    def self.from_json(json)
      new.tap do |file|
        file.id, file.kyc_profile_id, file.url, file.file_name, file.content_type, file.file_size = json
      end
    end

    def self.all
      Api.private(:get, '/kyc_files').map { |file| from_json(file) }
    end
  end
end
