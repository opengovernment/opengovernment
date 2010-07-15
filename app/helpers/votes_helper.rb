module VotesHelper
  CHART_URL = %q(http://chart.apis.google.com/chart?
      chbh=20
      &chs=#{CHART_WIDTH}x#{CHART_HEIGHT}
      &cht=bhs
      &chco=405695,B43030,666666
      &chds=0,#{total_votes},0,#{total_votes},0,#{total_votes}
      &chd=t:#{d.collect {|x| x.join(',') }.join('|')}
      &chm=@f#{votes_needed_to_pass} needed to pass,666666,1,0.2:0.2,12,,h
      |N*f0* Democrats,ffffff,0,0,12,,rc
      |N*f0* Republicans,ffffff,1,1,12,,rc
      |N*f0* Other,ffffff,1,2,12,,rc).gsub(/\n\s+/,'')

  CHART_WIDTH = 350
  CHART_HEIGHT = 120

  def vote_chart_img(vote_id)
    vote_types = ['yes', 'no', 'other']
    parties = [Legislature::MAJOR_PARTIES, nil].flatten
    
    d = []

    parties.each do |party|
      y = []
      vote_types.each do |vote_type|
        if party.nil?
          # Sadly, all other parties get lumped together
          y << Vote.count_by_sql(["select count(*) from v_district_votes where vote_id = ? and party not in (?) and vote_type = ?", vote_id, Legislature::MAJOR_PARTIES, vote_type])
        else
          y << Vote.count_by_sql(["select count(*) from v_district_votes where vote_id = ? and party = ? and vote_type = ?", vote_id, party, vote_type])
        end 
      end
      d << y
    end

    # TODO: This doesn't work in all circumstances, but for now we will go with
    # 1/2 of all members present and voting.
    total_votes = z.flatten.inject { |sum,n| sum + n }
    votes_needed_to_pass = total_votes / 2

    img = '<img src="' + eval('"' + CHART_URL + '"') + %Q{" width="#{CHART_WIDTH}" height="#{CHART_HEIGHT}" class="vote_chart" id="vote_#{vote_id}_chart">}
    return img.html_safe
  end

end
