module ScrapedDocument
  require 'open-uri'
  
  def self.included(base)
    base.class_eval do
      has_attached_file :document, :path => ':rails_root/public/system/:class/:id/:style/:filename'
      scope :without_local_document, where("url is not null and url != '' and document_file_name is null")

      # Right now this is used by OpenGov::BillTexts::sync! to
      # download documents for each bill.
      attr_accessor :document_url
      before_validation :download_file, :if => :url_provided?
      validates_presence_of :url, :if => :url_provided?, :message => 'is invalid or inaccessible'
    end
  end

  private

  def url_provided?
    !self.document_url.blank?
  end

  def download_file
    self.document = do_download_file
    self.url = document_url
  end

  def do_download_file
    io = open(URI.parse(document_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue OpenURI::HTTPError => e
    puts "OpenURL error: #{e}"
    # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end
end
