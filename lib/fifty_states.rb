require 'json'

module FiftyStates
  
  ROLE_MEMBER = "member"
  ROLE_COMMITTEE_MEMBER = "committee member"
  CHAMBER_UPPER = "upper"
  CHAMBER_LOWER = "lower"

  class FiftyStatesError < StandardError
    attr_reader :response

    def initialize(response, message = nil)
      @response = response
      @message  = message
    end

    def to_s
      "Failed with #{response.code} #{response.message if response.respond_to?(:message)}"
    end
  end

  class NotauthorizedError < FiftyStatesError;
  end

  class InvalidRequestError < StandardError;
  end

  class NotFoundError < FiftyStatesError;
  end

  class NameError < FiftyStatesError;
  end

  class Base
    include HTTParty
    format :json
    default_params :output => 'json'
    base_uri 'fiftystates-dev.sunlightlabs.com/api'

    attr_accessor :attributes

    def initialize(attributes = {})
      @attributes = {}
      unload(attributes)
    end

    class << self
      def instantiate_record(record)
        new(record)
      end

      def instantiate_collection(collection)
        collection.collect! { |record| instantiate_record(record) }
      end
    end

    def unload(attributes)
      raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      attributes.each do |key, value|
        @attributes[key.to_s] =
          case value
            when Array
              resource = resource_for_collection(key)
              value.map do |attrs|
                if attrs.is_a?(String) || attrs.is_a?(Numeric)
                  attrs.duplicable? ? attrs.dup : attrs
                else
                  resource.new(attrs)
                end
              end
            when Hash
              resource = find_or_create_resource_for(key)
              resource.new(value)
            else
              value.dup rescue value
          end
      end
      self
    end

    private
    def resource_for_collection(name)
      find_resource_for(name.to_s.singularize)
    end

    def find_resource_in_modules(resource_name, module_names)
      receiver = Object
      namespaces = module_names[0, module_names.size-1].map do |module_name|
        receiver = receiver.const_get(module_name)
      end
      if namespace = namespaces.reverse.detect { |ns| ns.const_defined?(resource_name) }
        return namespace.const_get(resource_name)
      else
        raise NameError, "Namespace for #{namespace} not found"
      end
    end

    def find_resource_for(name)
      resource_name = name.to_s.camelize
      ancestors = self.class.name.split("::")
      if ancestors.size > 1
        find_resource_in_modules(resource_name, ancestors)
      else
        self.class.const_get(resource_name)
      end
    rescue NameError
      #TODO: May be we should create new classes based on unknown records
    end

    def method_missing(method_symbol, *arguments) #:nodoc:
      method_name = method_symbol.to_s

      case method_name.last
        when "="
          attributes[method_name.first(-1)] = arguments.first
        when "?"
          attributes[method_name.first(-1)]
        when "]"
          attributes[arguments.first.to_s]
        else
          attributes.has_key?(method_name) ? attributes[method_name] : super
      end
    end
  end

  class State < Base
    def self.find_by_abbreviation(abbreviation)
      response = get("/#{abbreviation}")
      instantiate_record(response)
    end
  end

  class Bill < Base
    # http://fiftystates-dev.sunlightlabs.com/api/ca/20092010/lower/bills/AB667/
    def self.find(state_abbrev, session, chamber, bill_id)
      response = get("/#{state_abbrev}/#{session}/#{chamber}/bills/#{bill_id}/")
      instantiate_record(response)
    end

    def self.search(query, options = {})
      response = get('/bills/search', :query => {:q => query}.merge(options))
      instantiate_collection(response)
    end

    def self.latest(updated_since, state_abbrev)
      response = get('/bills/latest/', :query => {:updated_since => updated_since, :state => state_abbrev})
      instantiate_collection(response)
    end
  end

  class Legislator < Base
    def self.find(legislator_id)
      response = get("/legislators/#{legislator_id}")
      instantiate_record(response)
    end

    def self.search(options = {})
      response = get('/legislators/search', :query => options)
      instantiate_collection(response)
    end
  end

  class Session < Base; end

  class Role < Base; end

  class Action < Base; end

  class Vote < Base; end

  class Sponsor < Base; end

  class Version < Base; end

  class Source < Base; end
end
