class Page
  include MongoMapper::Document
  many :page_views

  key :url, String, :indexed => true
  key :countable_id, Integer, :required => true, :indexed => true
  key :countable_type, String, :required => true, :indexed => true

  attr_accessor :subdomain

  scope :by_object, lambda {|object_type, object_id| where({:countable_id => object_id, :countable_type => object_type}) }

  validate :should_be_unique
  
  MAP_FUNCTION = %q( function() {
        emit(this.page_id, this.total);
  } )

  REDUCE_FUNCTION = %q( function(key, values) {
      var total = 0;
      for ( var i=0; i<values.length; i++ ) {
        total += values[i];
      }
      return total;
  })
  
  def view_count
    return 0 if page_views.count == 0 || new_record?

    opts = {:query => {:page_id => self['_id']}, :out => 'temp_views' }

    mr = PageView.collection.map_reduce( MAP_FUNCTION, REDUCE_FUNCTION, opts )
    
    finder = mr.find.first
    (finder && finder["value"].to_i) || 0
  end

  def view_count_since(since)
    return 0 if page_views.count == 0 || new_record?

    opts = {:query => {'page_id' => self['_id'], 'hour' => { '$gt' => since.utc } }, :out => 'temp_views' }

    mr = PageView.collection.map_reduce( MAP_FUNCTION, REDUCE_FUNCTION, opts )
    
    finder = mr.find.first
    (finder && finder["value"].to_i) || 0
  end

  def mark_hit
    raise if new_record?

    if page_view = PageView.first_or_create({:page_id => id, :subdomain => subdomain, :hour => Time.now.beginning_of_hour})
      page_view.total += 1
      page_view.save
    end
  end

  def self.most_viewed(object_type, ops = {})
    ops[:limit] ||= 10

    mr_opts = { :query => {'countable_type' => object_type }, :out => 'temp_views' }

    if ops[:subdomain]
      mr_opts[:query]['subdomain'] = ops[:subdomain]
    end

    if ops[:since]
      mr_opts[:query]['hour'] = { '$gt' => ops[:since].try(:utc) }
    end

    begin
      top_views = PageView.collection.map_reduce( MAP_FUNCTION, REDUCE_FUNCTION, mr_opts )

      # p['value'] contains the total hit count, but we're not using it right now.
      top_views.find.sort([['value','descending']]).limit(ops[:limit]).collect { |p| Page.find(p['_id']) }
      
    # When we view this the very first time after installing MongoDB, the PageView collection doesn't yet exist.
    # But it will get created when a specific bill is viewed;
    # so for now, just catch the exception and continue.
    rescue Mongo::OperationFailure => e
      Rails.logger.info "Tried to read Mongodb when no db had been initialized."
      []
    end
  end

  protected
   def should_be_unique
     page = Page.first( :countable_type => countable_type,
                        :countable_id => countable_id )

     valid = (page.nil? || page.id == self.id)
     if !valid
       self.errors.add(:countable, "A page already exists for #{self.countable_type} #{self.countable_id}")
     end
   end

end

