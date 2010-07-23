module OpenGov
  class Resources
    def self.valid_date!(date)
      return nil unless date

      if [Float, Integer].any? { |x| date.kind_of?(x) }
        Time.at(date).to_date
      elsif date.kind_of?(String)
        begin
          return Date.parse(date)
        rescue ArgumentError
          return Chronic.parse(date)
        end
      elsif date.kind_of?(Date)
        date
      else
        raise TypeError, "We only know about floats, integers, and strings"
      end
    end

    def self.scale(i, from, to)
      sprintf("%.1f", (((i || 0).to_f / from) * to)).to_f
    end
  end
end
