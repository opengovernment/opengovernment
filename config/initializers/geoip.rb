if File.exists?(File.join(Rails.root, 'data/GeoLiteCity.dat'))
  GEOIP = GeoIP.new(File.join(Rails.root, 'data/GeoLiteCity.dat'))
else
  GEOIP = nil
end
