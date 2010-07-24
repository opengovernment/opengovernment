module OpenGov
  class Integer
    def self.scale(i, from, to)
      sprintf("%.1f", (((i || 0).to_f / from) * to)).to_f
    end
  end
end