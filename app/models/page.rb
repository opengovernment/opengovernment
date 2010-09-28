class Page
  include MongoMapper::Document
  many :views

  key :url, String, :indexed => true
  key :countable_id, Integer, :required => true, :indexed => true
  key :countable_type, String, :required => true, :indexed => true

  scope :by_object, lambda {|object_type, object_id| where({:countable_id => object_id, :countable_type => object_type}) }
  scope :most_viewed, lambda {|object_type| where(:countable_type => object_type).order("views desc").limit(10) }

  validate :should_be_unique

  def all_views
    return 0 if views.count == 0

    opts = {:query => { :countable_type => countable_type, :countable_id => countable_id}}

    map_function = %q( function() {
          for (var i = 0; i < this.views.length ; i++) {
            emit({type: this.countable_type, id: this.countable_id}, this.views[i].count);
          }
    } )

    reduce_function = %q( function(key, values) {
            var total = 0;
            for ( var i=0; i<values.length; i++ ) {
              total += values[i];
            }
            return total;
    })

    mr = collection.map_reduce( map_function, reduce_function, opts )
    
    finder = mr.find.first
    (finder && finder["value"].to_i) || 0
  end

  def views_since(since)
    return 0 if views.count == 0

    opts = {:query => { :countable_type => countable_type, :countable_id => countable_id } }
    map_function = %Q( function() {
          var d = new Date("#{since.utc}");
          for (var i = 0; i < this.views.length ; i++) {
            if (this.views[i].hour >= d) {
              emit({type: this.countable_type, id: this.countable_id}, this.views[i].count);
            }
          }
    } )

    reduce_function = %q( function(key, values) {
            var total = 0;
            for ( var i=0; i<values.length; i++ ) {
              total += values[i];
            }
            return total;
    })

    mr = collection.map_reduce( map_function, reduce_function, opts )
    
    finder = mr.find.first
    (finder && finder["value"].to_i) || 0
  end

  class << self
    def all_views_by_object_type
      collection.group(["og_object_type"], {}, {:views => 0}, "function(doc, prev) {prev.views += doc.views}", true)
    end

    def top_views_for(object_type, limit = 10)
      opts = {  }
      map_function = %Q( function() {
        for (var i = 0; i < this.views.length ; i++) {
          emit({type: this.countable_type, id: this.countable_id}, this.views[i].count);
        }
      } )

      reduce_function = %Q( function(key, values) {
              var total = 0;
              for ( var i=0; i<values.length; i++ ) {
                total += values[i];
              }
              return total;
      })

      top_views = collection.map_reduce( map_function, reduce_function, { } )

      top_views.find.where(:type => object_type).limit(limit).collect { |p| [Page.find(p['_id']), p['value']] }
    end
  end # self

  protected
   def should_be_unique
     page = Page.first( :countable_type => self.countable_type,
                        :countable_id => self.countable_id )

     valid = (page.nil? || page.id == self.id)
     if !valid
       self.errors.add(:countable, "A page already exists for #{self.countable_type} #{self.countable_id}")
     end
   end

end

