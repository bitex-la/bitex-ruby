module Bitex
  # La doooc
  class Client
    attr_accessor :api_key, :debug, :sandbox, :ssl_version

    attr_reader :orders

    Order = Struct.new(:client) do
      def method_missing(method_name, *args)
        block = proc { client }
        kind.respond_to?(method_name) ? kind.send(method_name, *args, &block) : super
      end

      def respond_to_missing?(method_name, include_private = false)
        kind.respond_to?(method_name) || super
      end

      private

      def kind
        Bitex::Order
      end
    end

    def initialize(api_key: '', debug: false, sandbox: false, ssl_version: nil)
      self.api_key = api_key.to_s
      self.debug = debug
      self.sandbox = sandbox
      self.ssl_version = ssl_version

      @orders = Order.new(self)
    end
  end
end
