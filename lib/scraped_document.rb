module ScrapedDocument
  require 'open-uri'

  def self.included(base)
    base.class_eval do
      has_attached_file :document, :path => ':rails_root/public/system/:class/:id_partition/:style/:filename', :url => '/system/:class/:id_partition/:style/:filename'
      scope :without_local_copy, where("url is not null and url != '' and document_file_name is null")

      around_save :queue_document_sync, :if => :refresh_document?
    end
  end

  def sync_document
    self.document = do_download_file
  end

  def refresh_document?
    !self.url.blank? && (self.url_changed? || !self.document?)
  end

  def queue_document_sync
    # Don't queue the job if we've already queued it.
    # And don't touch document_sync_queued if it's been explicitly set already.
    unless document_sync_queued? || document_sync_queued_changed?
      toggle(:document_sync_queued)
      yield # save
      Delayed::Job.enqueue(ScrapedDocumentJob.new(self.class, self.id))
    else
      yield # save
    end

    return true
  end

  private

  def do_download_file
    return nil if url.blank?

    io = open(URI.parse(url))
    def io.original_filename; base_uri.path.split('/').last; end
    # (content type is assigned by open-uri)
    io.original_filename.blank? ? nil : io
  rescue OpenURI::HTTPError => e
    # eg. 404
    puts "OpenURL error: #{e}"
    raise
  rescue SystemCallError => e
    # eg. connection reset by peer
    puts "System call error: #{e}"
    raise
  end

end
