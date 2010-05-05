class RemovePolymorphicOnActions < ActiveRecord::Migration
  def self.up
    change_table :actions do |t|
      t.rename :actor_id, :actor
      t.change :actor, :string
    end
  end

  def self.down
    change_table :actions do |t|
      t.rename :actor, :actor_id
      t.change :actor_id, :integer
    end
  end
end
