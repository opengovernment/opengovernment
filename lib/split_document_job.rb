class SplitDocumentJob < Struct.new(:document_type, :document_id)
  def perform
    if document = self.document_type.find(self.document_id)     
      if document.component_sync_queued?
        document.toggle!(:component_sync_queued)
        if document.document? && document.document_content_type == 'application/pdf' && File.exists?(document.document.path)
          document.sync_components
          document.save!
        end
      end
    end
  end

  def error
    # A permanent failure -- after 25 tries
    if document = self.document_type.find(self.document_id) && document.component_sync_queued?
      document.toggle!(:component_sync_queued)
    end
  end
end