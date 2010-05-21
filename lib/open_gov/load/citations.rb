module OpenGov::Load::Citations
  def self.import!
    puts "Importing citations for"
    Bill.all.each do |bill|
      puts "#{bill.bill_number}.."
      raw_citations = bill.raw_citations

      raw_citations[:google_news].map { |c| make_citation(bill, c, "Google News") }
      raw_citations[:google_blogs].map { |c| make_citation(bill, c, "Google Blogs") }

      bill.save!
      break
    end
  end

  def self.make_citation(bill, citation, source)
    begin
      c = bill.citations.find_or_initialize_by_source_and_date(citation.source, valid_date!(citation.date))
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
