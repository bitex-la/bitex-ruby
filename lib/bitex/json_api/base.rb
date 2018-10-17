module Bitex
  module JsonApi
    # Generic base resource for Bitex resources.
    class Base < JsonApiClient::Resource
      self.site = 'https://dev.bitex.la:3000/api/'

      # Set headers about request type
      #
      # @param [Symbol] type: [:public, :private].
      #
      # @return yield block
      def self.request(type)
        if type == :private
          connection_options[:headers] = { Authorization: Bitex.api_key }
        elsif connection_options[:headers].present?
          connection_options[:headers].try(:delete, :Authorization)
        end
        yield
      end

      def self.access_has_one(*args)
        instance_eval do
          args.each do |arg|
            define_method(arg) { relationships.send(arg.to_sym) }

            define_method("#{arg}=") { |val| relationships.send("#{arg.to_sym}=", val) }
          end
        end
      end

      def self.access_belongs_to(arg, options = {})
        instance_eval do
          belongs_to arg, options

          define_method(arg) { relationships.send(arg.to_sym) }

          define_method("#{arg}=") do |val|
            send("#{arg}_id=", val.id) if val.respond_to? :id
            send("#{arg}_type=", val.type)
            relationships.send("#{arg.to_sym}=", val)
          end
        end
      end

      def self.access_has_many(*args)
        instance_eval do
          args.each do |arg|
            define_method(arg) do
              instance_variable_get("@#{arg}") || instance_variable_set("@#{arg}", RelationshipManager.new(self, arg))
            end
          end
        end
      end

      def self.access_attributes(*args)
        instance_eval do
          args.each do |arg|
            define_method(arg) { self[arg.to_sym] }

            define_method("#{arg}=") { |val| self[arg.to_sym] = val }
          end
        end
      end
    end
  end
end
