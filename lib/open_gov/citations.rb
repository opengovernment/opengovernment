module OpenGov
  class Citations < Resources
    def self.import!
      import_bills
      import_people
    end
            
    def self.import_bills
      puts "Importing citations for bills.."
      Bill.with_key_votes.each do |bill|
        puts "#{bill.bill_number}.."
        raw_citations = bill.raw_citations

        raw_citations[:google_news].map { |c| make_citation(bill, c, "Google News") }
        raw_citations[:google_blogs].map { |c| make_citation(bill, c, "Google Blogs") }

        bill.save!
      end
    end

    def self.import_people
      puts "Importing citations for people..."
      Person.with_current_role.each do |person|
        puts "#{person.full_name}..."
        raw_citations = person.raw_citations
        raw_citations[:google_news].map { |c| make_citation(person, c, "Google News") }
        raw_citations[:google_blogs].map { |c| make_citation(person, c, "Google Blogs") }
      end
    end

    def self.make_citation(owner, citation, source)
      c = owner.citations.find_or_initialize_by_source_and_date(citation.source, Date.valid_date!(citation.date))
      c.url = citation.url
      c.weight = citation.weight
      # Remove HTML tags from citation title and excerpt
      c.title = Hpricot(citation.title).scrub
      c.excerpt = Hpricot(citation.excerpt).scrub
      c.search_source = source
      c.save!
    end
  end
end
