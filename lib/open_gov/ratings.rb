module OpenGov
  class Ratings < Resources
    class << self
      def import!
        import_issues
        import_sigs
        import_ratings
      end

      def import_issues
        puts "Deleting existing issues"
        Issue.delete_all
        # State.loadable.each do |state|
          begin
            puts "Importing issues.."
            categories = GovKit::VoteSmart::Category.list()
            categories.each do |kat|
              issue = Issue.find_or_initialize_by_votesmart_id(kat.categoryId)
              issue.name = kat.name
              issue.save!
            end
          rescue GovKit::ResourceNotFound
            puts "No resource found for #{state.abbrev}"
          end
        # end
      end

      def import_sigs
        puts "Deleting existing Special Interest Groups"
        SpecialInterestGroup.delete_all

        State.loadable.each do |state|
          puts "Importing Special Interest groups for .. #{state.name} "
          Issue.all.each do |issue|
            partial_sigs = GovKit::VoteSmart::SIG.list(issue.votesmart_id, state.abbrev).to_a

            partial_sigs && partial_sigs.each do |partial_sig|
              puts "Fetching SIG for ID: #{partial_sig.sigId}"
              begin
                remote_sig = GovKit::VoteSmart::SIG.find(partial_sig.sigId)
                sig = state.special_interest_groups.find_or_initialize_by_votesmart_id(remote_sig.sigId)
                sig.name = remote_sig.name
                sig.address = remote_sig.address
                sig.description = remote_sig.description
                sig.issue_id = issue.id
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
        end
      end

      def import_ratings
        puts "Deleting existing Special Interest Groups"
        Rating.delete_all

        Person.with_votesmart_id.with_current_role.each do |person|
          puts "Importing Ratings for .. #{person.full_name} "

          SpecialInterestGroup.all.each do |sig|
            remote_ratings = GovKit::VoteSmart::Rating.find(person.votesmart_id, sig.votesmart_id).to_a
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
