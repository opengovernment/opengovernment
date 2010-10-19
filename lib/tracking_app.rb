class TrackingApp
  def initialize(app, log = nil)
    @app = app
  end

  def self.call(env)
    gif_data = open('public/images/tracking.gif', 'rb') { |io| io.read }

    @request = Rack::Request.new(env)

    self.store

    [200, {'Content-type' => 'image/gif'}, [gif_data]]
  end

  def self.store
    if key = valid_cache_key(@request.params['object_type'], @request.params['object_id'], @request.ip)

      if Rails.cache.read(key)
        # Allow only one page hit per page per IP per hour.
        return
      else
        Rails.cache.write(key, true, :expires_in => 1.hour.from_now)

        page = Page.find_by_url(@request.params['u'])

        page ||= Page.create({
          :countable_id => @request.params['object_id'],
          :countable_type => @request.params['object_type'],
          :url => @request.params['u']
        })

        page.mark_hit
      end
    end
  end

  # Validate that we've received a correct object_type and id, and
  # return a cache key suitable for this object.
  def self.valid_cache_key(object_type, object_id, ip)
    klass = object_type.constantize
    if klass.superclass == ActiveRecord::Base && klass.exists?(object_id)
      return [ip, object_type, object_id].join(':')
    end
    nil
  end

end
