atom_feed(:root_url => url_for(:format => nil, :only_path => false)) do |feed|
  feed.title("Votes by #{@person.official_name}")
  feed.updated(@person.votes.first.try(:date))

  @roll_calls.each do |roll_call|
    bill = roll_call.vote.bill
    vote = roll_call.vote

    # We're overriding the ID here to match openstates' permanent vote ID, and
    # we're using the vote date as the published date. We do this because the vote
    # itself is replaced when the bill is updated. This decreases the number of
    # duplicate entries people will see in their feeds, but it's not entirely failsafe:
    # if a vote changes, the updated field in the entry won't change.
    feed.entry(vote, :id => "tag:#{request.host}:#{vote.class}/#{vote.openstates_id}", :published => vote.date, :updated => vote.date) do |entry|
      entry.title('Vote: ' + roll_call.vote_type + ' on ' + bill.bill_number + ' (' + vote.motion + ')')
      entry.content('On ' + vote.date.to_s(:pretty) + ', ' + @person.full_name + ' voted ' + content_tag(:b, roll_call.vote_type) + ' on the motion ' + link_to(vote.motion, vote_path(vote)) + ' of ' + link_to(bill.bill_number + ': ' + bill.title, bill_path(bill.session, bill)), :type => 'html')

      entry.author do |author|
        author.name("OpenGovernment")
        author.uri("http://opengovernment.org")        
      end
    end
  end
end
