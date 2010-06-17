module OpenGov
  class Citations < Resources
    class << self
      def import!
        puts "Importing citations for bills.."
        Bill.with_key_votes.each do |bill|
          puts "#{bill.bill_number}.."
          raw_citations = bill.raw_citations

          raw_citations[:google_news].map { |c| make_citation(bill, c, "Google News") }
          raw_citations[:google_blogs].map { |c| make_citation(bill, c, "Google Blogs") }

          bill.save!
        end
      end

      def make_citation(owner, citation, source)
        c = owner.citations.find_or_initialize_by_source_and_date(citation.source, valid_date!(citation.date))
        c.url = citation.url
        c.weight = citation.weight
        c.excerpt = citation.excerpt
        c.title = citation.title
        c.search_source = source
        c.save!
      end
    end
  end
end
