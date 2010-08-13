module OpenGov
  class Ratings < Resources
    class << self
      def import!
        import_categories
        import_sigs
        import_ratings
      end

      def import_categories
        puts "Deleting existing categories"
        Category.delete_all
        State.loadable.each do |state|
          begin
            puts "Importing categories.."
            categories = GovKit::VoteSmart::Category.list(state.abbrev)
            categories.each do |kat|
              category = Category.find_or_initialize_by_votesmart_id(kat.categoryId)
              category.name = kat.name
              category.save!
            end
          rescue GovKit::ResourceNotFound
            puts "No resource found for #{state.abbrev}"
          end
        end
      end

      def import_sigs
        puts "Deleting existing Special Interest Groups"
        SpecialInterestGroup.delete_all

        State.loadable.each do |state|
          puts "Importing Special Interest groups for .. #{state.name} "
          Category.all.each do |category|
            partial_sigs = GovKit::VoteSmart::SIG.list(category.votesmart_id, state.abbrev)

            # Essentially a to_a, but works on any object.
            partial_sigs = [*partial_sigs]

            if partial_sigs
              if partial_sigs.size == 1 && partial_sigs[0][0] == 'error'
                puts "Error with #{state.abbrev} sig in category #{category.votesmart_id}: #{partial_sigs[0][1]["errorMessage"]}; skipping"
              else
                partial_sigs.each do |partial_sig|
                  puts "Fetching SIG for ID: #{partial_sig.sigId}"
                  begin
                    remote_sig = GovKit::VoteSmart::SIG.find(partial_sig.sigId)
                    sig = state.special_interest_groups.find_or_initialize_by_votesmart_id(remote_sig.sigId)
                    sig.name = remote_sig.name
                    sig.address = remote_sig.address
                    sig.description = remote_sig.description
                    sig.category_id = category.id
                    sig.contact_name = remote_sig.contactName
                    sig.city = remote_sig.city
                    sig.address = remote_sig.address
                    sig.zip = remote_sig.zip
                    sig.url = remote_sig.url
                    sig.phone_one = remote_sig.phone1
                    sig.phone_two = remote_sig.phone2
                    sig.email = remote_sig.email
                    sig.fax = remote_sig.fax
                    sig.save!
                  rescue GovKit::ResourceNotFound
                    puts "No resource found for #{state.abbrev}"
                  end
                end
              end
            end # if partial_sigs
          end
        end
      end

      def import_ratings
        puts "Deleting existing ratings from Special Interest Groups"
        Rating.delete_all

        State.loadable.each do |state|
          puts "Importing Ratings for .. #{state.name}"

          state.people.with_votesmart_id.each do |person|
            puts "Importing Ratings for .. #{person.full_name} (#{person.votesmart_id})"
            state.special_interest_groups.each do |sig|
              remote_ratings = [*GovKit::VoteSmart::Rating.find(person.votesmart_id, sig.votesmart_id)]
              if remote_ratings.size == 1 && remote_ratings[0][0] == 'error'
                puts "Error with #{person.full_name} (#{person.votesmart_id}) ratings in sig #{sig.votesmart_id}: #{remote_ratings[0][1]["errorMessage"]}; skipping"
              else
                remote_ratings.each do |rr|
                  rating = person.ratings.find_or_initialize_by_votesmart_id(rr.ratingId)
                  rating.rating = rr.rating
                  rating.rating_text = rr.ratingText
                  rating.timespan = rr.timespan
                  rating.sig_id = SpecialInterestGroup.find_by_votesmart_id(rr.sigId).id
                  rating.save
                end
              end
            end
          end
        end
      end
    end
  end
end
