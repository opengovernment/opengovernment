class RenameRollToRollcalls < ActiveRecord::Migration
  def self.up
    rename_table "rolls", "roll_calls"
  end

  def self.down
    rename_table "roll_calls", "rolls"    
  end
end
