attributes :full_name, :created_at, :district_name, :party, :permalink, :views
code(:websites) { |p| [p.website_one, p.website_two].compact }
attributes :webmail, :bio_url, :youtube_id, :openstates_updated_at, :opensecrets_id, :transparencydata_id, :id, :gender, :first_name, :last_name, :suffix, :birthday, :religion, :middle_name, :email

attributes :bio_data => :bio, :photo_url => :original_photo_url

child(:roles) {
  attributes :start_date, :end_date, :chamber_id, :created_at, :session, :senate_class, :party, :state_id
}

code(:photo_urls) { |p| {:original => p.photo.url, :full => p.photo.url(:full), :thumb => p.photo.url(:thumb)} }
