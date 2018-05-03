module Bitex
  class ApiError < StandardError
  end

  class Api
    def self.grab_curl
      if @curl
        @curl.reset
      else
        @curl = Curl::Easy.new
      end

      @curl.ssl_version = Curl::CURL_SSLVERSION_TLSv1
      @curl.on_debug { |t, d| puts "DEBUG SSL #{t}, #{d}" if d.to_s.size < 300 } if Bitex.debug
      @curl.connect_timeout = 30
      @curl.timeout = 30
      @curl
    end

    def self.curl(verb, path, options = {}, files = {})
      verb = verb.upcase.to_sym
      query = verb == :GET ? "?#{options.to_query}" : ''
      prefix = Bitex.sandbox ? 'sandbox.' : ''

      curl = grab_curl
      curl.url = "https://#{prefix}bitex.la/api-v1/rest#{path}#{query}"

      if verb == :POST
        fields = []
        unless files.empty?
          fields += files.map { |k, v| Curl::PostField.file(k.to_s, v) }
          curl.multipart_form_post = true
        end
        fields += options.map do |k, v|
          next unless v
          Curl::PostField.content(k.to_s, v)
        end.compact
        curl.send("http_#{verb.downcase}", *fields)
      else
        curl.put_data = options.to_query if verb == :PUT
        curl.http(verb)
      end
      code = curl.response_code

      unless [200, 201, 202].include?(code)
        raise ApiError, "Got #{code} fetching #{path} with #{options}\n\n#{curl.head}\n\n#{curl.body}"
      end

      curl
    end

    def self.public(path, options = {})
      response = curl(:GET, path)
      JSON.parse(response.body)
    end

    def self.private(verb, path, options = {}, files = {})
      raise StandardError, 'No api_key available to make private key calls' if Bitex.api_key.nil?
      response = curl(verb, path, options.merge(api_key: Bitex.api_key), files)
      JSON.parse(response.body)
    end

    # Deserialize a single object from a json representation as specified on the bitex API class reference
    # @see https://bitex.la/developers#api-class-reference
    def self.deserialize(object)
      {
        1 => Bid,
        2 => Ask,
        3 => Buy,
        4 => Sell,
        5 => SpecieDeposit,
        6 => SpecieWithdrawal,
        7 => UsdDeposit,
        8 => UsdWithdrawal
      }[object[0]].from_json(object)
    end

    # @visibility private
    def self.from_json(thing, json, &block)
      thing.tap do |t|
        t.id = json[1]
        t.created_at = Time.at(json[2])
        block.call(t)
      end
    end
  end
end
