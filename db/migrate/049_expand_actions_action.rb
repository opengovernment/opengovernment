class ExpandActionsAction < ActiveRecord::Migration
  def self.up
    execute 'drop view v_tagged_actions'
    change_column :actions, :action, :text
    puts "****** Please re-run rake db:sqlseed to restore database views. ******"
  end

  def self.down
    execute 'drop view v_tagged_actions'
    change_column :actions, :action, :string
    puts "*** Please re-run rake db:sqlseed to restore database views. ***"
  end
end
