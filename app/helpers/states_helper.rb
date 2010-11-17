module StatesHelper

  STATE_MAP_URL = %q(#{Settings.geoserver_base_url}/wms?
    service=WMS
    &request=GetMap
    &version=1.1.1
    &transparent=true
    &layers=topp:states,cite:v_district_people
    &bbox=#{state.bbox.join(",")}
    &cql_filter=STATE_ABBR='#{state.abbrev}';chamber_id+=+#{chamber.id}
    &width=#{width}
    &height=#{height}
    &format=image/png
    &SLD=#{CGI::escape(sld_url)}).gsub(/\n\s+/,'')

  def leg_map_img(state, chamber)
    width, height = 180, (180 * state.bbox_aspect_ratio).to_i

    sld_url = request ? "#{request.protocol}#{request.host_with_port}/people.xml" : "http://localhost:3000/people.xml"
    image_tag(eval('"' + STATE_MAP_URL + '"'), :alt => "#{state.name} #{chamber.name}", :width => width, :height => height)
  end

end