module OpenGov::Load::Citations
  def self.import!
    puts "Importing citations for bills.."
    Bill.with_key_votes.each do |bill|
      puts "#{bill.bill_number}.."
      raw_citations = bill.raw_citations

      raw_citations[:google_news].map { |c| make_citation(bill, c, "Google News") }
      raw_citations[:google_blogs].map { |c| make_citation(bill, c, "Google Blogs") }

      bill.save!
    end
#
#    puts "Importing citations for people.."
#    Person.all.each do |person|
#      puts "#{person.full_name}.."
#      raw_citations = person.raw_citations
#
#      raw_citations[:google_news].map { |c| make_citation(person, c, "Google News") }
#      raw_citations[:google_blogs].map { |c| make_citation(person, c, "Google Blogs") }
#
#      person.save!
#    end
  end

  def self.make_citation(owner, citation, source)
    begin
      c = owner.citations.find_or_initialize_by_source_and_date(citation.source, valid_date!(citation.date))
      c.url = citation.url
      c.weight = citation.weight
      c.excerpt = citation.excerpt
      c.title = citation.title
      c.search_source = source
      c.save!
    rescue
      puts "Skipping citation.."
    end
  end

  def self.valid_date!(date)
    Date.parse(date) rescue nil
  end
end
