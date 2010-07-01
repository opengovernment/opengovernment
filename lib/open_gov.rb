module OpenGov
  class Resources
    def self.valid_date!(date)
      begin
        Date.parse(date) || Time.at(date).to_date 
      rescue
        nil
      end
    end
  end
end
