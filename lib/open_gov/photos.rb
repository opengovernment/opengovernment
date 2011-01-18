module OpenGov
  class Photos < Resources
    def self.import!
      puts "Importing photos from VoteSmart"
      i, s = 0, 0
      Person.with_votesmart_id.with_current_role.where("photo_url is null").each do |person|
        begin
          bio = GovKit::VoteSmart::Bio.find(person.votesmart_id)
          i += 1

          # puts "Updating #{person.to_param}"
          unless bio.photo.blank?
            person.photo_url = bio.photo
            #puts "Updating #{person.to_param}"
            person.save
          else
            s += 1
          end
        rescue GovKit::ResourceNotFound
          puts "No bio found for #{person.to_param}"
        end	 	
      end 	
      puts "#{i} photos found; #{s} skipped."
    end
  end
end
