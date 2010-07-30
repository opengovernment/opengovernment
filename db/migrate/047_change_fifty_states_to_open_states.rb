class ChangeFiftyStatesToOpenStates < ActiveRecord::Migration
  def self.up
    ["bills", "votes", "people", "committees"].each do |table|
      rename_column table, :fiftystates_id, :openstates_id
    end

    rename_column "people", :fiftystates_photo_url, :openstates_photo_url
  end

  def self.down
    ["bills", "votes", "people", "committees"].each do |table|
      rename_column table, :openstates_id, :fiftystates_id
    end

    rename_column "people", :openstates_photo_url, :fiftystates_photo_url
  end
end
