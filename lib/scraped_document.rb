module ScrapedDocument
  def self.included(base)
    base.has_attached_file :document
  end
  
  private

  def url_provided?
    !self.url.blank?
  end

  def download_file
    self.document = do_download_file
    self.openstates_photo_url = url
  end

  def do_download_file
    io = open(URI.parse(url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue OpenURI::HTTPError => e
    puts "OpenURL error: #{e}"
    # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end
end
