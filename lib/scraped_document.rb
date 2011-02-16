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

  def sync_document!
    self.document = do_download_file
    self.save!
  end

  def refresh_document?
    !self.url.blank? && (self.url_changed? || !self.document?)
  end

  private

  def queue_document_download
    Delayed::Job.enqueue(ScrapedDocumentJob.new(self.class, self.id)) if self.url?
  end

  def do_download_file
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
