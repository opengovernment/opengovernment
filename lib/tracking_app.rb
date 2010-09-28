class TrackingApp
  def initialize(app, log = nil)
    @app = app
  end

  def self.call(env)
    gif_data = open('public/images/tracking.gif', 'rb') { |io| io.read }
    req = Rack::Request.new(env)

    self.store(req)

    [200, {'Content-type' => 'image/gif'}, [gif_data]]
  end

  def self.store(request)
    page = Page.find_by_url(request.params['u'])

    page ||= Page.create({
                        :countable_id => request.params['object_id'],
                        :countable_type => request.params['object_type'],
                        :url => request.params['u']
                      })

    page.mark_hit
  end
end
