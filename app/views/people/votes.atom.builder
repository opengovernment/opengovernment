atom_feed(:root_url => url_for(:format => nil, :only_path => false)) do |feed|
  feed.title("Votes by #{@person.official_name}")
  feed.updated(@person.votes.first.try(:date))

  @roll_calls.each do |roll_call|
    bill = roll_call.vote.bill
    vote = roll_call.vote

    feed.entry(vote) do |entry|
      entry.title('Vote: ' + roll_call.vote_type + ' on ' + bill.bill_number + ' (' + vote.motion + ')')
      entry.content('On ' + vote.date.to_s(:pretty) + ', ' + @person.full_name + ' voted ' + content_tag(:b, roll_call.vote_type) + ' on the motion ' + link_to(vote.motion, vote_path(vote)) + ' of ' + link_to(bill.bill_number + ': ' + bill.title, bill_path(bill.session, bill)), :type => 'html')

      entry.author do |author|
        author.name("OpenGovernment")
        author.uri("http://opengovernment.org")        
      end
    end
  end
end
