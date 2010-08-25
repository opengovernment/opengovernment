module HomeHelper
  def interactive_us_map
    # w, h, and f variables are subsitutions and are used during the eval() of the map url.
    unless ['development', 'test'].include?(Rails.env)
      w = HomeController::MAP_WIDTH
      h = HomeController::MAP_HEIGHT

      states_map_tag = Rails.cache.read('states_map_tag')
      if states_map_tag.nil?
        f = "text/html"
        map_uri = URI.parse(eval('"' + HomeController::MAP_POST_URL + '"'))
        http = Net::HTTP.new(map_uri.host, map_uri.port)
        http.open_timeout = 15 # in seconds
        http.read_timeout = 15 # in seconds

        # The request.
        req = Net::HTTP::Get.new(map_uri.request_uri)
        res = http.request(req)

        states_map_tag = res.body
        Rails.cache.write('states_map_tag', states_map_tag)
      end

      f = "image/png"
      %Q{<img src="#{eval('"' + HomeController::MAP_POST_URL + '"')}" width="#{HomeController::MAP_WIDTH}" height="#{HomeController::MAP_HEIGHT}" alt="USA" usemap="#states" />}.html_safe + states_map_tag.html_safe
    end
  end
end
