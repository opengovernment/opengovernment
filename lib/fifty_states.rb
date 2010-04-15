module FiftyStates
  require 'json'

  FIFTYSTATES_URL = 'http://fiftystates-dev.sunlightlabs.com/api'

  # These classes encapsulate the results of calls to the Fifty States API
  class FiftyStateObject
    class << self
      attr_reader :attrs

      def from_json(json)
        self.new ActiveSupport::JSON.decode(json)
      end

      def get(uri)
        puts "getting #{uri} #{@attrs.inspect}"
        if uri = URI.parse(uri)
          res = get_uri(uri)
          return res unless res.kind_of?(Net::HTTPOK)
          self.from_json(res.body)
        end
      end

      def search(uri)
        puts "getting #{uri} #{@attrs.inspect}"
        if uri = URI.parse(uri)
          res = get_uri(uri)
          return res unless res.kind_of?(Net::HTTPOK)
          ActiveSupport::JSON.decode(res.body).collect { |x| self.new x }
        end
      end

      private

      def get_uri(uri)
        Net::HTTP.start(uri.host, uri.port) do |http|
          http.get(uri.request_uri)
        end
      end
    end

    def initialize(h={})
      self.class.attrs.each do |var|
        eval("@#{var.to_s} = h['#{var.to_s}']")
      end
    end

    def hash
      res={}
      self.class.attrs.each { |s| res[s] = self.send(s.to_s) }

      res
    end
    alias to_hash hash

  end

  class State < FiftyStateObject
    @attrs = [:name, :abbreviation, :legislature_name, :upper_chamber_name, :lower_chamber_name, :upper_chamber_term, :lower_chamber_term, :upper_chamber_title, :lower_chamber_title, :sessions]

    attr_reader *@attrs

    class << self
      def get(state_abbrev)
        super [FiftyStates::FIFTYSTATES_URL, state_abbrev.downcase, ''].join('/')
      end
    end

  end

  class Bill < FiftyStateObject
    @attrs = [:title, :state, :session, :chamber, :bill_id, :actions, :sponsors]

    attr_reader *@attrs

    class << self
      def get(state_abbrev, session, chamber, bill_id)
        return nil unless ['upper', 'lower'].include?(chamber)
        super URI.escape([State.uri_for(state_abbrev).chop, session, chamber.downcase, 'bills', bill_id, ''].join('/'))
      end

      def search(q, ops = {})
        ops[:q] = q

        return nil unless ['upper', 'lower', nil].include?(ops[:chamber])

        query = []
        [:q, :state, :session, :chamber, :updated_since].each do |v|
          query.push("#{v}=" + ops[v]) if ops[v]
        end
        super URI.escape([FIFTYSTATES_URL, 'bills', 'search', ''].join('/') + '?' + query.join('&'))
      end
    end
  end

  class LatestBills < FiftyStateObject
    @attrs = [:bills]
    attr_reader *@attrs

    class << self
      def get(state_abbrev, updated_since)
        query = "updated_since=#{updated_since}&state=#{state_abbrev}"
        super URI.escape([FIFTYSTATES_URL, 'bills', 'latest', ''].join('/') + '?' + query)
      end
    end
  end

  class Legislator < FiftyStateObject
    @attrs = [:leg_id, :full_name, :first_name, :last_name, :middle_name, :suffix, :party, :roles, :nimsp_candidate_id, :votesmart_id, :updated_at]
    attr_reader *@attrs

    class << self
      def get(leg_id)
        super URI.escape([FIFTYSTATES_URL, 'legislators', leg_id, ''].join('/'))
      end

      def search(ops = {})
        query = []
        [:state, :first_name, :last_name, :middle_name, :party, :session, :district].each do |v|
          query.push("#{v}=" + ops[v]) if ops[v]
        end

        super URI.escape([FIFTYSTATES_URL, 'legislators', 'search', ''].join('/') + '?' + query.join('&'))
      end
    end
  end

end
