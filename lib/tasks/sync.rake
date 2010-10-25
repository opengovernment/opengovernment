desc "Sync OpenGovernment data"
task :sync => :environment do

end

namespace :sync do
  desc "Open States API data"
  task :openstates => :environment do
    OpenGov::Fetch::States.process
  end

  desc "Fetch latest GeoIP dataset (updated monthly)"
  task :geoip => :environment do
    geoip_url = 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz'

    FileUtils.mkdir_p(Settings.data_dir)
    Dir.chdir(Settings.data_dir)
    puts "---------- Downloading GeoIP datafile"
    `curl -fO #{geoip_url}`
    `gzip -df #{File.basename(geoip_url)}`
  end

  desc "Fetch photos and attach them to people"
  task :photos => :environment do
    OpenGov::Photos.sync!
  end

  desc "Fetch bill full text and associated documents"
  task :bill_texts => :environment do
    OpenGov::BillTexts.sync!
  end

end
