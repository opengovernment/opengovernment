module VotesHelper
  CHART_URL = %q(http://chart.apis.google.com/chart?
      chbh=#{bar_height}
      &chs=#{width}x#{height}
      &cht=bhs
      &chco=405695,B43030,999999
      &chds=0,#{total_votes},0,#{total_votes},0,#{total_votes}
      &chf=bg,s,65432100
      &chd=t:#{data_table}
      &chm=#{CGI::escape markers}).gsub(/\n\s+/,'')

  # If a given bar is more than 100 pixels long, it's safe to show the label.
  LABEL_MIN_WIDTH = 80

  def vote_chart_image_tag(vote)

    height, width = 100, 300
    bar_height = 20

    vote_types = ['yes', 'no', 'other']
    parties = [Legislature::MAJOR_PARTIES, nil].flatten

    # Gather the votes for each party and type
    votes = []

    parties.each do |party|
      party_name = party || "Other"
      y = []
      vote_types.each do |vote_type|
        if party.nil?
          # Sadly, all other parties get lumped together
          y << Vote.count_by_sql(["select count(*) from v_district_votes where vote_id = ? and party not in (?) and vote_type = ?", vote.id, Legislature::MAJOR_PARTIES, vote_type]) + Vote.count_by_sql(["select v.#{vote_type}_count - (select count(*) from v_district_votes dv where dv.vote_id = ? and dv.vote_type = ?) as missing_votes from votes v where v.id = ?", vote.id, vote_type, vote.id])
        else
          y << Vote.count_by_sql(["select count(*) from v_district_votes where vote_id = ? and party = ? and vote_type = ?", vote.id, party, vote_type])
        end 
      end
      votes << party_name
      votes << y
    end

    # Our array now looks something like this:
    #  => ['Democrat', [64, 0, 3], 'Republican', [18, 52, 3], 'Other', [0, 0, 0]]
    counts_only = votes.select { |x| x.instance_of?(Array) }

    total_votes = counts_only.flatten.inject { |sum,n| sum + n }

    if total_votes > 0
      logger.debug "Total votes: #{total_votes}"

      # Where are we going to place the "votes needed to pass" label?
      votes_needed_y_ratio = Integer.scale(vote.needed_to_pass, total_votes, width) / width

      # Google's marker format -- see Chart API docs for chm=
      markers = "@f#{vote.needed_to_pass} needed to pass*,666666,1,0.2:#{votes_needed_y_ratio},12,,h"

      # Pull out all the arrays of values, and put them into the Google Charts table format
      # This will give us three data series (one for each party), with three values each.
      data_table = counts_only.collect {|x| x.join(',') }.join('|')

      # Here we're figuring out which of the values it's safe to apply a label to.
      # The label will be "32 Democrats", for example.
      # But we only want to label a bar if it's long enough to fit the text.
      pixels_per_vote = width / total_votes
      party_name = ''
      votes.each_with_index do |h, i|
        if i % 2 == 0
          party_name = h.pluralize
        else
          h.each_with_index do |c, j|
            series_index = (i-1) / 2
            if c * pixels_per_vote > LABEL_MIN_WIDTH
              # (The actual votes value is pulled from the data table)
              markers += "|N*f0* #{party_name},ffffff,#{series_index},#{j},10,,hc"
            end
          end
        end
      end

      return image_tag(eval('"' + CHART_URL + '"'), :width => width, :height => height, :class => 'vote_chart')
    else
      "Sorry, not enough data to display a chart"
    end
  end

  MAP_URL = %q(#{Settings.geoserver_base_url}/wms?
    service=WMS
    &request=GetMap
    &version=1.1.1
    &transparent=true
    &layers=topp:states,cite:v_district_votes
    &bbox=#{state.bbox.join(",")}
    &cql_filter=STATE_ABBR='#{state.abbrev}';vote_id+=+#{vote_id}
    &width=#{width}
    &height=#{height}
    &format=image/png
    &SLD=#{CGI::escape(sld_url)}).gsub(/\n\s+/,'')

  def vote_map_img(state, vote_id)
    width = 300

    # The image aspect ratio must match the bounding box of the map being rendered
    height = (width * state.bbox_aspect_ratio).to_i

    sld_url = request ? "#{request.protocol}#{request.host_with_port}/votes.xml" : "http://localhost:3000/votes.xml"
    return image_tag(eval('"' + MAP_URL + '"'), :width => width, :height => height, :class => 'vote_map', :alt => "Geography of the vote")
  end

  def vote_legend_img
    return image_tag('votes/map_legend.png', :class => 'vote_legend')
  end
end