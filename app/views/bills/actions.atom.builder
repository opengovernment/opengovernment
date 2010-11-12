atom_feed(:root_url => url_for(:format => nil, :only_path => false)) do |feed|
  feed.title(t('bills.rss.feed_title', :state_name => @bill.state.name, :chamber_name => @bill.chamber.name, :bill_number => @bill.bill_number, :actions_shown => @actions_shown.to_s))
  feed.updated(@bill.last_action_at)

  for action in @actions
    feed.entry(action) do |entry|
      entry.title(action.action)
      entry.content(action.description, :type => 'html')

      entry.author do |author|
        author.name(t('bills.rss.author_name'))
        author.uri(t('bills.rss.author_uri'))
      end
    end
  end
end
