module OpenGov
  class Mentions < Resources
    def self.import!
      import_bills
      import_people
    end

    def self.import_bills
      puts "Importing mentions for bills with key votes.."
      Bill.with_key_votes.each do |bill|
        make_mentions(bill)
      end
      
      puts "Importing mentions for bills most viewed..."
      Bill.without_key_votes.most_viewed(:since => 30.days.ago, :limit => 100).each do |bill|
        make_mentions(bill)
      end
    end

    def self.import_people
      puts "Importing mentions for people with current roles..."
      Person.with_current_role.each do |person|
        make_mentions(person)
      end
    end

    def self.make_mentions(obj)
      puts "#{obj.to_param}"
      raw_mentions = obj.raw_mentions

      raw_mentions[:google_news].map { |c| make_mention(obj, c, "Google News") }
      raw_mentions[:google_blogs].map { |c| make_mention(obj, c, "Google Blogs") }

      obj.save!
    end

    def self.make_mention(owner, mention, source)
      c = owner.mentions.find_or_initialize_by_source_and_date(mention.source, Date.valid_date!(mention.date))
      c.url = mention.url
      c.weight = mention.weight
      c.title = mention.title
      c.excerpt = mention.excerpt
      c.search_source = source
      c.save!
    end
  end
end
