class ScrapedDocumentJob < Struct.new(:object_class, :object_id)
  def perform
    object_class.find(object_id).sync_document!
  end
end