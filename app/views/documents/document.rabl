attributes :name, :created_at, :updated_at, :published_at, :total_pages, :description
attributes :document_content_type => :content_type, :document_file_size => :size, :url => :source_url
code(:permalink) { |d| d.document.url }
