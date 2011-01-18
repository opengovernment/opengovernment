module OpenGov
  class Bios < Resources
    def self.import!
      puts 'Fetching bios for all current people with transparencydata ids'

      f, u, s = 0, 0, 0
      Person.with_transparencydata_id.each do |person|
        begin
          begin
            td_person = GovKit::TransparencyData::Entity.find_by_id(person.transparencydata_id)
          rescue GovKit::ResourceNotFound
            puts "No results found for TransparencyData entity #{person.transparencydata_id}."
          end

          # Attempt to fetch WikiPedia bio from TransparencyData first...
          if td_person && td_person[:metadata] && td_person[:metadata][:bio] && td_person[:metadata][:bio_url]
            print "T"
            bio = td_person[:metadata][:bio]
            bio_url = td_person[:metadata][:bio_url]
          else
            print "W"
            bio = GovKit::SearchEngines::Wikipedia.search(person.wiki_name)
            bio_url = person.wikipedia_url
          end

          unless bio.blank?
            u += 1
            person.bio_data = bio
            person.bio_url = bio_url
            # puts "Updating #{person.to_param}"
            person.save
          else
            s += 1
            # puts "Skipping..no bio data found"
          end

          $stdout.flush
        rescue GovKit::ResourceNotFound
          s += 1
          # puts "No bio found for #{person.to_param}"
        rescue Timeout::Error
          s += 1
          puts "Timed out while fetching #{person.wiki_name}"
        end
      end # Person.each
      puts "Fetched #{f} bios, updated #{u} people, skipped #{s} bios"
    end
  end
end
