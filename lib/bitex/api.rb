module Bitex
  class ApiError < Exception; end
  class Api
    def self.curl(verb, path, options={})
      verb = verb.upcase.to_sym
      query = verb == :GET ? "?#{options.to_query}" : ''

      curl = Curl::Easy.new("https://bitex.la/api-v1/rest#{path}#{query}")
      curl.post_body = options.to_query if verb == :POST
      curl.http(verb)
      code = curl.response_code

      unless [200, 201, 202].include?(code)
        raise ApiError.new("Got #{code} fetching #{path} with #{options}")
      end

      return curl
    end
    
    def self.public(path, options={})
      JSON.parse(curl(:GET, path).body)
    end
    
    def self.private(verb, path, options={})
      if Bitex.api_key.nil?
        raise Exception.new("No api_key available to make private key calls")
      end
      JSON.parse(curl(verb, path, options.merge(api_key: Bitex.api_key)).body)
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
