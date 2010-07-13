module OpenGov
  class Bios < Resources
    class << self
      def import!
        puts 'Fetching bios for all current people with votesmart_ids'

        f, u, s = 0, 0, 0
        Person.with_votesmart_id.with_current_role.each do |person|
          begin
            # puts "Fetching bio data for #{person.wiki_name}"
            bio =  GovKit::SearchEngines::Wikipedia.search(person.wiki_name)
            f += 1

            if f % 10 == 0
              print '.'
              $stdout.flush
            end
  
            unless bio.blank?
              u += 1
              person.bio_data = bio
              # puts "Updating #{person.to_param}"
              person.save
            else
              s += 1
              # puts "Skipping..no bio data found"
            end

          rescue GovKit::ResourceNotFound
            s += 1
            # puts "No bio found for #{person.to_param}"
          end
        end # Person.each
        puts "Fetched #{f} bios, updated #{u} people, skipped #{s} bios"
      end
    end
  end
end
