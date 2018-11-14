module Bitex
  # Map all methods to a JsonApi::Resource sending custom headers for requests.
  class Forwarder
    def initialize(resource, api_key = nil)
      @resource = resource
      @api_key = api_key
    end

    def method_missing(method_name, *args, &block)
      return super unless @resource.respond_to?(method_name)

      options = args.extract_options!
      # Bug: Double splat does not work on empty hash assigned via variable
      # https://bugs.ruby-lang.org/issues/11860
      args << options unless options.empty?

      @resource.with_headers(headers(options)) { @resource.send(method_name, *args, &block) }
    end

    def respond_to_missing?(method_name, include_private = false)
      @resource.respond_to?(method_name) || super
    end

    def headers(options = {})
      { Authorization: @api_key, version: Bitex::VERSION }.tap do |header|
        header.merge!('One-Time-Password' => options[:otp]) if options.key?(:otp)
      end
    end
  end
end
