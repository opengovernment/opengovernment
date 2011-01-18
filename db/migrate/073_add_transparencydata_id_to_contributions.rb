class AddTransparencydataIdToContributions < ActiveRecord::Migration
  def self.up
    add_column :contributions, :transparencydata_id, :string, :limit => 50
  end

  def self.down
    remove_column :contributions, :transparencydata_id
  end
end