module StatesHelper

  STATE_MAP_URL = %q(#{GEOSERVER_BASE_URL}/wms?
    service=WMS
    &request=GetMap
    &version=1.1.1
    &layers=cite:v_district_people
    &bbox=#{state.bbox.join(",")}
    &cql_filter=state_id+=+#{state.id}+and+chamber_id+=+#{chamber.id}
    &width=300
    &height=300
    &format=image/png
    &SLD=#{CGI::escape(sld_url)}).gsub(/\n\s+/,'')

  def leg_map_img(state, chamber)
    sld_url = request ? "#{request.protocol}#{request.host_with_port}/people.xml" : "http://localhost:3000/people.xml"
    image_tag(eval('"' + STATE_MAP_URL + '"'), :alt => "#{state.name} #{chamber.name}", :width => 300, :height => 300)
  end

end