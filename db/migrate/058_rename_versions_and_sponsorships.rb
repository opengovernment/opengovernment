class RenameVersionsAndSponsorships < ActiveRecord::Migration
  def self.up
    rename_table :versions, :bill_versions
    rename_table :sponsorships, :bill_sponsorships
    rename_column :bills, :kind, :kind_one
    add_column :bills, :kind_two, :string
    add_column :bills, :kind_three, :string

    create_table :bill_documents do |t|
      t.references :bill
      t.string :name, :limit => 4000
      t.string :url, :limit => 8000
    end

    add_column :roll_calls, :committee, :string
    add_column :roll_calls, :threshold, :float
    add_column :bills, :alternate_titles, :string, :limit => 20000
    add_column :bills, :short_title, :string, :limit => 1000

    rename_column :actions, :kind, :kind_one
    add_column :actions, :kind_two, :string
    add_column :actions, :kind_three, :string
  end

  def self.down
    rename_table :bill_versions, :versions
    rename_table :bill_sponsorships, :sponsorships
    rename_column :bills, :kind_one, :kind
    remove_column :bills, :kind_two
    remove_column :bills, :kind_three

    drop_table :bill_documents

    remove_column :roll_calls, :committee
    remove_column :roll_calls, :threshold
    remove_column :bills, :alternate_titles
    remove_column :bills, :short_title
    
    rename_column :actions, :kind_one, :kind
    remove_column :actions, :kind_two
    remove_column :actions, :kind_three
  end
end
