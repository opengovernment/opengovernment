class AddPersonIdToRollCalls < ActiveRecord::Migration
  def self.up
    rename_column :roll_calls, :leg_id, :person_id
  end

  def self.down
    rename_column :roll_calls, :person_id, :leg_id
  end
end
