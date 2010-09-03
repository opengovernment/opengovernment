class AddVotesAndBillsKind < ActiveRecord::Migration
  def self.up
    add_column :sponsorships, :sponsor_name, :string
    add_column :votes, :kind, :string
    add_column :bills, :kind, :string
  end

  def self.down
    remove_column :sponorships, :sponsor_name
    remove_column :votes, :kind
    remove_column :bills, :kind
  end
end
