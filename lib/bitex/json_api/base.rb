module Bitex
  module JsonApi
    class Base < JsonApiClient::Resource
      self.site = 'https://8f305d7f-8d8a-4793-a2d6-6c97c2b4d5ca.mock.pstmn.io/api/'

      def self.find(*args)
        super(*args)[0]
      end

      def self.access_has_one(*args)
        instance_eval do
          args.each do |arg|
            define_method(arg) do
              self.relationships.send(arg.to_sym)
            end

            define_method("#{arg}=") do |val|
              self.relationships.send("#{arg.to_sym}=", val)
            end
          end
        end
      end

      def self.access_belongs_to(arg, options = {})
        instance_eval do
          belongs_to arg, options

          define_method(arg) do
            #self.relationships.send(arg.to_sym)
          end

          define_method("#{arg}=") do |val|
            self.send("#{arg}_id=", val.id) if val.respond_to? :id
            self.send("#{arg}_type=", val.type)
            self.relationships.send("#{arg.to_sym}=", val)
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
            define_method(arg) do
              self[arg.to_sym]
            end

            define_method("#{arg}=") do |val|
              self[arg.to_sym] = val
            end
          end
        end
      end
    end

    Base.connection do |connection|
      # TODO aca tengo que hacer algo pero no recuerdo que
    end
  end
end
