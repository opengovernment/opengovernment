module HomeHelper
  def interactive_us_map
    unless ['development', 'test'].include?(Rails.env)
      Rails.cache.delete('states_map_tag')
      states_map_tag = Rails.cache.read('states_map_tag')
      if states_map_tag.nil?
        f = "text/html"
        w = HomeController::MAP_WIDTH
        h = HomeController::MAP_HEIGHT
        uri = URI.parse(eval('"' + HomeController::MAP_POST_URL + '"'))
        http = Net::HTTP.new(uri.host, uri.port)
        http.open_timeout = 4 # in seconds
        http.read_timeout = 4 # in seconds

        # The request.
        req = Net::HTTP::Get.new(uri.request_uri)
        res = http.request(req)

        states_map_tag = res.body
        Rails.cache.write('states_map_tag', states_map_tag)
      end

      %Q{<img src="/us_map.png" width="#{HomeController::MAP_WIDTH}" height="#{HomeController::MAP_HEIGHT}" alt="USA" usemap="#states" />}.html_safe + states_map_tag.html_safe
    end
  end
end
