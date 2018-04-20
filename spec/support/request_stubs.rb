require 'open-uri'

module RequestStubs
  def stub_get(path, fixture)
    stub_api(:get, path, fixture, {})
  end

  def stub_private(method, path, fixture, options = {})
    options[:api_key] = 'valid_api_key'
    stub_api(method, path, fixture, options)
  end

  def stub_api(method, path, fixture, options)
    params =
      if method == :get
        { query: options }
      elsif method == :put
        { body: options.to_query }
      else
        { body: options.map { |k, v| "#{k}=#{CGI.escape(v.to_s).gsub('+', '%20')}" } * '&' }
      end

    stub_request(method, "https://bitex.la/api-v1/rest#{path}")
      .with(params)
      .to_return(status: 200, body: File.read(fixture_path(fixture)))
  end

  def fixture_path(filename)
    File.expand_path("../../fixtures/#{filename}.json", __FILE__)
  end
end
