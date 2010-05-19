atom_feed do |feed|
  feed.title(@bill.title)
  feed.updated(@bill.last_action_at)

  for action in @bill.actions
    feed.entry(action) do |entry|
      entry.title(action.action)
      entry.content(action.description, :type => 'html')

      entry.author do |author|
        author.name("OpenGovernment")
      end
    end
  end
end
