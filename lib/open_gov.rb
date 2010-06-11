module OpenGov
  class Resources
    def self.valid_date!(date)
      Date.parse(date) rescue nil
    end
  end
end
