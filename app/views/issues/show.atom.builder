atom_feed(:root_url => url_for(:format => nil, :only_path => false)) do |feed|
  feed.title(@issue.name)
#  feed.updated(@issue.)

  for action in @actions
    feed.entry(action) do |entry|
      entry.title("#{action.bill.bill_number}:" + action.action)
      entry.subtitle(action.description)
      entry.content(action.description, :type => 'html')
      entry.updated(action.date)

      entry.author do |author|
        author.name("OpenGovernment")
      end
    end
  end
end
