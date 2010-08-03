module VotesHelper
  CHART_URL = %q(http://chart.apis.google.com/chart?
      chbh=20
      &chs=#{CHART_WIDTH}x#{CHART_HEIGHT}
      &cht=bhs
      &chco=405695,B43030,999999
      &chds=0,#{total_votes},0,#{total_votes},0,#{total_votes}
      &chd=t:#{data_table}
      &chm=#{CGI::escape markers}).gsub(/\n\s+/,'')

  CHART_WIDTH = 300
  CHART_HEIGHT = 100

  # If a given bar is more than 100 pixels long, it's safe to show the label.
  LABEL_MIN_WIDTH = 80

  def vote_chart_img(vote_id)
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
          y << Vote.count_by_sql(["select count(*) from v_district_votes where vote_id = ? and party not in (?) and vote_type = ?", vote_id, Legislature::MAJOR_PARTIES, vote_type]) + Vote.count_by_sql(["select v.#{vote_type}_count - (select count(*) from v_district_votes dv where dv.vote_id = ? and dv.vote_type = ?) as missing_votes from votes v where v.id = ?", vote_id, vote_type, vote_id])
        else
          y << Vote.count_by_sql(["select count(*) from v_district_votes where vote_id = ? and party = ? and vote_type = ?", vote_id, party, vote_type])
        end 
      end
      votes << party_name
      votes << y
    end

    # Our array now looks something like this:
    #  => ["Democrat", [64, 0, 3], "Republican", [18, 52, 3], "Other", [0, 0, 0]]
    counts_only = votes.select { |x| x.instance_of?(Array) }

    total_votes = counts_only.flatten.inject { |sum,n| sum + n }

    if total_votes > 0
      logger.debug "Total votes: #{total_votes}"
      # TODO: This doesn't work in all circumstances, but for now we will go with
      # 1/2 of all members present and voting.
      votes_needed_to_pass = total_votes / 2

      # Where are we going to place the "votes needed to pass" label?
      votes_needed_y_ratio = Integer.scale(votes_needed_to_pass, total_votes, CHART_WIDTH) / CHART_WIDTH

      # Pull out all the arrays of values, and put them into the Google Charts table format
      # This will give us three data series (one for each party), with three values each.
      data_table = counts_only.collect {|x| x.join(',') }.join('|')

      # Google's marker format -- see Chart API docs for chm=
      markers = "@f#{votes_needed_to_pass} needed to pass,666666,1,0.2:#{votes_needed_y_ratio},12,,h"

      # Here we're figuring out which of the values it's safe to apply a label to.
      # The label will be "32 Democrats", for example.
      # But we only want to label a bar if it's long enough to fit the text.
      pixels_per_vote = CHART_WIDTH / total_votes
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

      return image_tag(eval('"' + CHART_URL + '"'), :width => CHART_WIDTH, :height => CHART_HEIGHT, :class => 'vote_chart')
    else
      "Sorry, not enough data to display a chart"
    end
  end

  MAP_URL = %q(http://localhost:8080/geoserver/wms?
    service=WMS
    &request=GetMap
    &version=1.1.1
    &layers=topp:states,cite:v_district_votes
    &bbox=#{state.bbox.join(",")}
    &cql_filter=STATE_ABBR='#{state.abbrev}';vote_id+=+#{vote_id}+and+chamber_id+=+#{chamber_id}
    &width=#{MAP_WIDTH}
    &height=#{MAP_HEIGHT}
    &format=image/png
    &SLD=#{CGI::escape(sld_url)}).gsub(/\n\s+/,'')

  MAP_WIDTH = 300
  MAP_HEIGHT = 300

  def vote_map_img(state, chamber_id, vote_id)
    sld_url = request ? "#{request.protocol}#{request.host_with_port}/votes.xml" : "http://localhost:3000/votes.xml"
    return image_tag(eval('"' + MAP_URL + '"'), :width => MAP_WIDTH, :height => MAP_HEIGHT, :class => 'vote_map', :alt => "Geography of the vote")
  end

  def vote_legend_img
    return image_tag('votes/map_legend.png', :class => 'vote_legend')
  end
end