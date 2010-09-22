class PageView
  include MongoMapper::Document
  key :url, String, :required => true, :indexed => true
  key :og_object_id, Integer, :indexed => true
  key :og_object_type, String, :indexed => true
  key :hour, Date
  key :views, Integer
#  key :uniques, Integer
 
  scope :by_object, lambda {|object_type, object_id| where({:og_object_id => object_id, :og_object_type => object_type}) }
  scope :most_viewed, lambda {|object_type| where(:og_object_type => object_type).order("views desc").limit(10) }

  class << self
    def view_count_for(object_type, object_id)
      by_object(object_type, object_id).first.try(:views).try(:count) || 0
    end
  
    def top_views_for(object_type, limit = 10)
      opts = {  }
      map_function = %Q( function() {
            var page = db.pages.find(this.page_id).next();
            emit(page.og_object_type + '-' + page.og_object_id, 1);
      } )

      reduce_function = %Q( function(key, values) {
              var total = 0;
              for ( var i=0; i<values.length; i++ ) {
                total += values[i];
              }
              return total;

      })

      top_views = View.collection.map_reduce( map_function, reduce_function, { } )

      top_views.find.limit(limit).collect { |p| [Page.find(p['_id']), p['value']] }
    end
  end
  
end

