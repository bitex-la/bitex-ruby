module Bitex
  module JsonApi
    # Generic base resource for Bitex resources.
    class Base < JsonApiClient::Resource
      self.site = 'https://dev.bitex.la:3000/api/'

      # type: [:public, :private]
      def self.request(type)
        JsonApi::Base.connection { |conn| conn.use "Bitex::JsonApi::#{type.capitalize}Request".constantize }
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
