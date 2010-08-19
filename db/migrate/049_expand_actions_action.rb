class ExpandActionsAction < ActiveRecord::Migration
  def self.up
    execute 'drop view v_tagged_actions'
    execute 'drop view v_tagged_bills'
    change_column :actions, :action, :string, :limit => 10000
    change_column :people, :website_one, :string, :limit => 2000
    change_column :people, :website_two, :string, :limit => 2000
    change_column :people, :webmail, :string, :limit => 2000
    change_column :bills, :title, :string, :limit => 64000
    puts "****** Please re-run rake db:sqlseed to restore database views. ******"
  end

  def self.down
    execute 'drop view v_tagged_actions'
    execute 'drop view v_tagged_bills'
    change_column :actions, :action, :string
    change_column :people, :website_one, :string
    change_column :people, :website_two, :string
    change_column :people, :webmail, :string
    change_column :bills, :title, :text
    puts "*** Please re-run rake db:sqlseed to restore database views. ***"
  end
end
