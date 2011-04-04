module SplitDocument
  # A mixin for splitting & OCRing documents with DocSplit.
  # Models must have the following columns:
  # -  A (paperclip) attached "document" (this is our source file),
  # -  total_pages, :integer
  # -  name, :string
  # -  description, :text
  # -  components_available, :boolean
  #
  # This mixin populates total_pages and components_available but not the others.
  
  def self.included(base)
    base.class_eval do
      after_save :destroy_components, :unless => :document?
      before_save :queue_component_sync, :if => :refresh_components?
      before_destroy :destroy_components
    end
  end

  def refresh_components?
    self.document_updated_at_changed?
  end

  def sync_components
    # We're going to repopulate these even if they exist already.
    destroy_components
  
    if document?
      pwd = Dir.pwd
      output_dir = File.join(Rails.root, 'public/system/dv', self.class.to_s.tableize, id_partition)
      large_output_dir = File.join(output_dir, 'large')
      normal_output_dir = File.join(output_dir, 'normal')

      begin
        if FileUtils.mkdir_p(output_dir)
          # Pushd
          pwd = Dir.pwd
          Dir.chdir(output_dir)

          # Output goes to cwd
          Docsplit.extract_images(document.path, :size => ['1000x','700x', '90x'], :format => :png, :rolling => true)

          # Fix the directory names of output pngs
          FileUtils.mv('1000x', 'large')
          FileUtils.mv('700x', 'normal')
          FileUtils.mv('90x', 'small')
        
          # Popd
          Dir.chdir(pwd)

          Docsplit.extract_text(document.path, :ocr => false, :pages => 'all', :output => output_dir)
          self.total_pages = Docsplit.extract_length(document.path)
          self.components_available = true
        end
      rescue
        Dir.chdir(pwd)
        raise
      end
    end
  end

  def id_partition
    # 12 => ['000','000','012']
    self[:id].to_s.rjust(9, '0').scan(/.../)
  end

  def components_path
    File.join(Rails.root, 'public/system/dv', self.class.to_s.tableize, id_partition)
  end

  def components_base_url
    File.join('/system/dv/', self.class.to_s.tableize, id_partition)
  end

  def text_url_format
    File.join(components_base_url, File.basename(document_file_name, File.extname(document_file_name)) + '_{page}.txt')
  end

  def image_url_format
    File.join(components_base_url, '{size}', File.basename(document_file_name, File.extname(document_file_name)) + '_{page}.png')
  end


  def queue_component_sync
    unless component_sync_queued?
      Delayed::Job.enqueue(SplitDocumentJob.new(self.class, self.id))
      toggle!(:component_sync_queued)
    end
    true
  end

  private

  def destroy_components
    if File.exists?(components_path)
      file_list = Dir.entries(components_path) - ['.','..']
      file_list.collect! { |fn| File.join(components_path, fn) }

      file_list.each do |path|
        begin
          Rails.logger.debug("deleting #{path}")
          FileUtils.rm_r(path) if File.exist?(path)
        rescue Errno::ENOENT => e
          # ignore file-not-found, let everything else pass
        end

        begin
          while(true)
            path = File.dirname(path)
            FileUtils.rmdir(path)
            break if File.exists?(path) # Ruby 1.9.2 does not raise if the removal failed.
          end
        rescue Errno::EEXIST, Errno::ENOTEMPTY, Errno::ENOENT, Errno::EINVAL, Errno::ENOTDIR
          # Stop trying to remove parent directories
        rescue SystemCallError => e
          log("There was an unexpected error while deleting directories: #{e.class}")
          # Ignore it
        end
      end
    end

    toggle!(:components_available) if components_available?

    return true
  end

end