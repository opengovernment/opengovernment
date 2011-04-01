module ScrapedDocument
  require 'open-uri'

  def self.included(base)
    base.class_eval do
      has_attached_file :document, :path => ':rails_root/public/system/:class/:id_partition/:style/:filename', :url => '/system/:class/:id_partition/:style/:filename'
      scope :without_local_copy, where("url is not null and url != '' and document_file_name is null")

      before_update :queue_document_download, :if => :refresh_document?
      after_create :queue_document_download
    end
  end

  def sync_document
    self.document = do_download_file
  end

  def document_download_job
    if document_sync_queued?
      sync_document
      toggle(:document_sync_queued)
      save!
    end
  end

  def refresh_document?
    !self.url.blank? && (self.url_changed? || !self.document?)
  end

  def queue_document_download
    # Don't queue the job if we've already queued it.
    unless document_sync_queued?
      toggle(:document_sync_queued)
      delay.document_download_job
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
