require 'vcr'

VCR.config do |c|
  c.cassette_library_dir = 'features/vcr_cassettes'
  c.stub_with :webmock
end

VCR.cucumber_tags do |t|
  t.tags '@uses_geocoder', :record => :none
end
