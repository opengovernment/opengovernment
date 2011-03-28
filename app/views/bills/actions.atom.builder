atom_feed(:root_url => url_for(:format => nil, :only_path => false)) do |feed|
  feed.title(t('bills.rss.feed_title', :state_name => @bill.state.name, :chamber_name => @bill.chamber.name, :bill_number => @bill.bill_number, :actions_shown => @actions_shown.to_s))
  feed.updated(@bill.last_action_at)

  # This has a similar issue as people/votes.atom.builder: hard to tell when
  # things change. We're using md5 here for the ID
  for action in @actions
    feed.entry(action, :id => "tag:#{request.host}:#{action.class}/#{action.to_md5}", :published => action.date, :updated => action.date) do |entry|
      entry.title(action.action)
      entry.content(action.description, :type => 'html')

      entry.author do |author|
        author.name(t('bills.rss.author_name'))
        author.uri(t('bills.rss.author_uri'))
      end
    end
  end
end
