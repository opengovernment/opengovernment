module OpenGov
  class BillTexts
    def self.sync!
      puts "Attaching bill versions and documents"
      [BillDocument, BillVersion].each do |type|
        type.without_local_copy.each do |p|
          puts "Attaching #{p.url}"
          p.document_url = p.url
          p.save
          sleep 0.1
        end
      end
    end
  end
end
