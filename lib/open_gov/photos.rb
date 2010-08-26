module OpenGov
  class Photos < Resources
    class << self
      def import!
        puts "Importing photos from VoteSmart"
        i = 0
        Person.with_votesmart_id.with_current_role.each do |person|
          begin
            bio = GovKit::VoteSmart::Bio.find(person.votesmart_id)
            i += 1

            # puts "Updating #{person.to_param}"
            unless bio.photo.blank?
              person.votesmart_photo_url = bio.photo
              #puts "Updating #{person.to_param}"
              person.save
            else
              puts "Skipping..no photo found"
            end

          rescue GovKit::ResourceNotFound
            puts "No bio found for #{person.to_param}"
          end
        end
      end
      
      # Load photos from the URLs in our db, and add them as attachments to
      # the person.
      def sync!
        puts "Resizing, cropping, and attaching photos to people"
        Person.with_photo_url.each do |p|
          # Net::URI.get(p.photo_url)
          # put the data in a local file
          # p.photo = File
          # p.save
        end
      end
      
    end
  end
end
