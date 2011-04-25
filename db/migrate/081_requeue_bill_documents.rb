class RequeueBillDocuments < ActiveRecord::Migration
  def self.up
    puts "Adding bill documents back to the delayed_job queue"
    BillDocument.find_each(:conditions => "document_content_type = 'application/pdf' and components_available = 'f' and component_sync_queued = 'f'") do |bd|
      if bd.document?
       bd.queue_component_sync
      elsif !bd.url.blank?
        bd.queue_document_download
        bd.save
      end
    end
    
  end

  def self.down
  end
end
