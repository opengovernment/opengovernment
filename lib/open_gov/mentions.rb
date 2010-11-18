module OpenGov
  class Mentions < Resources
    def self.import!
      import_bills
      import_people
    end

    def self.import_bills
      puts "Importing mentions for bills.."
      Bill.with_key_votes.each do |bill|
        puts "#{bill.bill_number}.."
        raw_mentions = bill.raw_mentions

        raw_mentions[:google_news].map { |c| make_mention(bill, c, "Google News") }
        raw_mentions[:google_blogs].map { |c| make_mention(bill, c, "Google Blogs") }

        bill.save!
      end
    end

    def self.import_people
      puts "Importing mentions for people..."
      Person.with_current_role.each do |person|
        puts "#{person.full_name}..."
        raw_mentions = person.raw_mentions
        raw_mentions[:google_news].map { |c| make_mention(person, c, "Google News") }
        raw_mentions[:google_blogs].map { |c| make_mention(person, c, "Google Blogs") }
      end
    end

    def self.make_mention(owner, mention, source)
      c = owner.mentions.find_or_initialize_by_source_and_date(mention.source, Date.valid_date!(mention.date))
      c.url = mention.url
      c.weight = mention.weight
      c.search_source = source
      c.save!
    end
  end
end
