atom_feed(:root_url => url_for(:format => nil, :only_path => false)) do |feed|
  feed.title(@bill.title)
  feed.updated(@bill.last_action_at)

  for action in @actions
    feed.entry(action) do |entry|
      entry.title(action.action)
      entry.content(action.description, :type => 'html')
      entry.updated(action.date)

      entry.author do |author|
        author.name("OpenGovernment")
      end
    end
  end
end
