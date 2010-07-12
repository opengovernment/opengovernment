module OpenGov
  class Bios < Resources
    class << self
      def import!
        Person.with_votesmart_id.with_current_role.each do |person|
          begin
            puts "Fetching bio data for #{person.wiki_name}"
            bio =  GovKit::SearchEngines::Wikipedia.search(person.wiki_name)

            unless bio.blank?
              person.bio_data = bio
              puts "Updating #{person.to_param}"
              person.save
            else
              puts "Skipping..no bio data found"
            end

          rescue GovKit::ResourceNotFound
            puts "No bio found for #{person.to_param}"
          end
        end
      end
    end
  end
end
