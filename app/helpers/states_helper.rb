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

  def state_bills_graph(state)
    now = Date.today
    ago = (now - 1.year).beginning_of_month

    counts = state.bills.
      where(['first_action_at BETWEEN ? AND ?', ago, now]).
      group("date_trunc('month', first_action_at)").
      order("date_trunc('month', first_action_at)").
      count

    counts.keys.each {|key| counts[Date.parse(key)] = counts.delete(key)}

    values = []
    month = ago
    while month <= now
      values << (counts[month] || 0)
      month = month.next_month
    end

    labels = [
      [
        now.years_ago(1).strftime("%b %Y"),
        [9, 6, 3].map { |m| now.months_ago(m).strftime("%b") },
        now.strftime("%b %e")
      ].flatten,
      [values.max]
    ]
    title_elements = [state.legislature.name, 'Bills Introduced']

    raw(
      Gchart.bar(:title => title_elements.join('|'),
        :data => values,
        :width => 400, :height => 130,
        :axis_range => [[0, 13], [0, values.max]],
        :axis_with_labels => 'x,y',
        :axis_labels => labels,
        :bar_colors => '36676F',
        :custom => "chxp=0,0.5,3.5,6.5,9.5,12.5|1,#{values.max}",
        :format => 'image_tag', :alt => title_elements.join(' : ')))
  end

  def render_search_results(results)
    output = ""
    results.each do |result_item|
      case result_item
      when Person
        output << render(:partial => "people/person", :locals => { :person => result_item})
      when Bill
        output << render(:partial => 'shared/bill', :locals => {:hide_key_vote => false, :bill => result_item })
      when Committee
        output << render(:partial => "shared/committee", :locals => {:committee => result_item})
      end
    end
    output
   end

end
