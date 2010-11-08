atom_feed(:root_url => url_for(:format => nil, :only_path => false)) do |feed|
  feed.title("#{@bill.state.name} #{@bill.chamber.name} Bill #{@bill.bill_number} - #{@actions_shown.to_s} actions")
  feed.updated(@bill.last_action_at)

  for action in @actions
    feed.entry(action) do |entry|
      entry.title(action.action)
      entry.content(action.description, :type => 'html')

      entry.author do |author|
        author.name("OpenGovernment")
        author.uri("http://opengovernment.org")        
      end
    end
  end
end
