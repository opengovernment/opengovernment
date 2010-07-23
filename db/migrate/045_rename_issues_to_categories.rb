class RenameIssuesToCategories < ActiveRecord::Migration
  def self.up
    rename_table :issues, :categories
    change_table :special_interest_groups do |t|
      t.rename :issue_id, :category_id
    end
  end

  def self.down
    rename_table :categories, :issues
    change_table :special_interest_groups do |t|
      t.rename :category_id, :issue_id
    end
  end
end
