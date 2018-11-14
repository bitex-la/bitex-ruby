# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitex/version'

Gem::Specification.new do |spec|
  spec.name          = 'bitex'
  spec.version       = Bitex::VERSION
  spec.authors       = ['Nubis', 'Eromirou', 'Jas']
  spec.email         = ['nb@bitex.la', 'tr@bitex.la', 'juan@bitex.la']
  spec.description   = %q{API client library for bitex.la. Fetch public market data and build trading robots}
  spec.summary       = 'API client library for bitex.la'
  spec.homepage      = 'http://bitex.la/developers'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'curb', '~> 0.9.3'

  spec.required_ruby_version = '>= 2.0'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'

  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rspec-mocks'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'shoulda-matchers'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
end
