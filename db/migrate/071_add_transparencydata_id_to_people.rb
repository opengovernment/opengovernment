class AddTransparencydataIdToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :transparencydata_id, :string
  end

  def self.down
    remove_column :people, :transparencydata_id
  end
end
