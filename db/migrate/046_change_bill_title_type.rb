class ChangeBillTitleType < ActiveRecord::Migration
  def self.up
    change_column :bills, :title, :text
  end

  def self.down
    change_column :bills, :title, :string
  end
end
