module RequestStubs
  def stub_get(path, fixture)
    stub_api(:get, path, fixture, {})
  end
  
  def stub_private(method, path, fixture, options = {})
    stub_api(method, path, fixture, options.merge({api_key: 'valid_api_key'}))
  end
  
  def stub_api(method, path, fixture, options)
    fixture_path = File.expand_path("../../fixtures/#{fixture}.json", __FILE__)
    with = method == :get ? {query: options} : {body: options.to_query}
    stub_request(method, "https://bitex.la/api-v1/rest#{path}")
      .with(with)
      .to_return(status: 200, body: File.read(fixture_path))
  end
end
