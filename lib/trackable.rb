# This is a model mixin providing some helper methods for page views.
# This helps us do a high-level join of Mongo's records with the corresponding
# model objects.
#
# Note: This module depends on the explicit_order extension, which is pgSQL-specific.
#
module Trackable
  module ClassMethods
    # This method always returns an AR scope, even though
    # it accesses mongodb.
    def most_viewed(ops = {})
      # Accept 'mn.staging' or whatever request.subdomain
      # might contain as a subdomain param.
      ops[:subdomain] = ops[:subdomain].split('.').try(:first) || ops[:subdomain]
      
      return self.none unless MongoMapper.connected?

      # This is gnarly. We have to generate a case statement for PostgreSQL in order to
      # get the people out in page view order. AND we need an SQL in clause for the people.

      # It does result in only one SQL call, though.
      # Good thing this is only ever limited to 10 or 20 items.
      countable_ids = Page.most_viewed(self.to_s, :limit => 100, :subdomain => ops[:subdomain], :since => ops[:since]).collect(&:countable_id)

      return self.none if countable_ids.empty?

      self.find_in_explicit_order(self.table_name + '.' + self.primary_key, countable_ids)
    end
  end

  def self.included(other)
    other.class_eval do
      # An empty scope, so we can always return a scope from most_viewed
      scope :none, lambda { where("1 = 0") }
    end
    
    other.extend ClassMethods
  end

  def page
    Page.by_object(self.class.to_s, self.id).first
  end

  def views(since=nil)
    return 0 unless MongoMapper.connected? && page

    if since
      page.view_count_since(since)
    else
      page.view_count
    end
  end

end
