class AddLoginToUsers < ActiveRecord::Migration
  def self.up
    # only migrate systems that don't tie into the opencongress database
    unless ActiveRecord::Base.configurations.has_key?('opencongress')
      add_column :users, :login, :string
      add_column :users, :salt, :string, :limit => 40
    end
  end

  def self.down
    unless ActiveRecord::Base.configurations.has_key?('opencongress')
      remove_column :users, :login, :salt
    end
  end
end
