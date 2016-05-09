module Bitex
  class ApiError < StandardError; end
  class Api
    def self.grab_curl
      if @curl
        @curl.reset
      else
        @curl = Curl::Easy.new
      end

      @curl.ssl_version = Curl::CURL_SSLVERSION_TLSv1
      if Bitex.debug
        @curl.on_debug do |t,d|
          if d.to_s.size < 300
            puts "DEBUG SSL #{t}, #{d}"
          end
        end
      end

      @curl.connect_timeout = 30
      @curl.timeout = 30
      @curl
    end

    def self.curl(verb, path, options={}, files={})
      verb = verb.upcase.to_sym
      query = verb == :GET ? "?#{options.to_query}" : ''
      prefix = Bitex.sandbox ? 'sandbox.' : ''

      curl = grab_curl
      curl.url = "https://#{prefix}bitex.la/api-v1/rest#{path}#{query}"
      
      if verb == :POST
        fields = []
        unless files.empty?
          fields += files.collect{|k, v| Curl::PostField.file(k.to_s, v) }
          curl.multipart_form_post = true
        end
        fields += options.collect do |k,v|
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
        raise ApiError.new("Got #{code} fetching #{path} with
#{options}\n\n#{curl.head}\n\n#{curl.body}")
      end

      return curl
    end
    
    def self.public(path, options={})
      c = curl(:GET, path)
      JSON.parse(c.body)
    end
    
    def self.private(verb, path, options={}, files={})
      if Bitex.api_key.nil?
        raise StandardError.new("No api_key available to make private key calls")
      end
      c = curl(verb, path, options.merge(api_key: Bitex.api_key), files)
      JSON.parse(c.body)
    end
    
    # Deserialize a single object from a json representation as specified on the
    # bitex API class reference
    # @see https://bitex.la/developers#api-class-reference
    def self.deserialize(object)
      { 1 => Bid,
        2 => Ask,
        3 => Buy,
        4 => Sell,
        5 => SpecieDeposit,
        6 => SpecieWithdrawal,
        7 => UsdDeposit,
        8 => UsdWithdrawal,
      }[object.first].from_json(object)
    end
    
    # @visibility private
    def self.from_json(thing, json, with_specie=false, &block)
      thing.id = json[1]
      thing.created_at = Time.at(json[2])
      if with_specie
        thing.specie = {1 => :btc, 2 => :ltc}[json[3]]
      end
      block.call(thing)
      return thing
    end
  end
end
