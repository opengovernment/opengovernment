module OpenGov
  class Resources
    def self.valid_date!(date)
      return nil unless date

      case date.class.to_s
      when 'Float', 'Integer'
        Time.at(date).to_date 
      when 'String'
        Date.parse(date)
      when 'Date'
        date
      else
        raise TypeError, "We only know about floats, integers, and strings"
      end

    end
  end
end
