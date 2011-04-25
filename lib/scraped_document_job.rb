class ScrapedDocumentJob < Struct.new(:document_type, :document_id)
  def perform
    if document = self.document_type.find(self.document_id)     
      if document.document_sync_queued?
        document.sync_document
        document.toggle(:document_sync_queued)
        document.save!
      end
    end
  end

  def failure
    # A permanent failure -- after 25 tries
    if document = self.document_type.find(self.document_id)
      document.toggle!(:document_sync_queued)
    end
  end
end