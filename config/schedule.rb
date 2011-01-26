# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Whenever Examples: https://github.com/javan/whenever/wiki/instructions-and-examples

# For OpenGovernment, whenver is only installed on production (see config/deploy/production.rb)

every 1.day do
  rake "sync:openstates"

  # sync:photos syncs people photo URLs with votesmart API.
  # Unfortunately, when we run sync:photos it causes sync:openstates to repopulate people.photo_url (often with nulls)
  # later on. So I'm turning this off for now.
  # rake "sync:photos"

  rake "load:mentions"
end

# GeoIP data is updated upstream monthly.
every 1.month do
  rake "fetch:geoip"
end

# Learn more: http://github.com/javan/whenever
