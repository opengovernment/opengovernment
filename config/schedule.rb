# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Whenever Examples: https://github.com/javan/whenever/wiki/instructions-and-examples

#every 1.day do
#  rake "sync:openstates sync:photos"
#end

# GeoIP data is updated upstream monthly.
every 1.month do
  rake "fetch:geoip"
end

# Learn more: http://github.com/javan/whenever
