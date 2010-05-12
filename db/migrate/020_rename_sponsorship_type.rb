class RenameSponsorshipType < ActiveRecord::Migration
  def self.up
    rename_column :sponsorships, :type, :kind
  end

  def self.down
    rename_column :sponsorships, :kind, :type
  end
end
