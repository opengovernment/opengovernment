module OpenGov
  class Mentions < Resources
    def import
      import_bills
      import_people
    end

    def import_bills
      puts "Importing mentions for bills with key votes.."
      Bill.with_key_votes.in_a_current_session.each do |bill|
        make_mentions(bill)
      end

      puts "Importing mentions for bills most viewed..."
      Bill.without_key_votes.in_a_current_session.most_viewed(:since => 30.days.ago).each do |bill|
        make_mentions(bill)
      end
    end

    def import_people
      puts "Importing mentions for people with current roles..."
      Person.with_current_role.each do |person|
        make_mentions(person)
      end
    end

    private

    def make_mentions(obj)
      puts "#{obj.to_param}"
      raw_mentions = obj.raw_mentions

      raw_mentions[:google_news].map { |c| make_mention(obj, c, "Google News") }
      raw_mentions[:google_blogs].map { |c| make_mention(obj, c, "Google Blogs") }

      obj.save!
    end

    def make_mention(owner, mention, source)
      owner.mentions.find_or_create_by_url(mention.url) do |c|
        c.source = mention.source[0..253]
        c.date = Date.valid_date!(mention.date)
        c.weight = mention.weight
        c.title = mention.title
        c.excerpt = mention.excerpt
        c.search_source = source
      end
    end
  end
end
