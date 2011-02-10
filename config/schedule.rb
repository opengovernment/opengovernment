# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Whenever Examples: https://github.com/javan/whenever/wiki/instructions-and-examples

# For OpenGovernment, whenever is only installed on production (see config/deploy/production.rb)

env :MAILTO, 'develop@opengovernment.org'

set :job_template, "bash -l -c 'rvm use ree@og && :job'"

# OpenStates' data should be updated by 4am ET.
# Our server is in central time zone.
every 1.day, :at => '3am' do
  rake "sync:openstates"
  rake "load:mentions"
  rake "load:keyvotes"
end

# GeoIP data is updated upstream monthly.
every 1.month do
  rake "fetch:geoip"
end

# Learn more: http://github.com/javan/whenever
