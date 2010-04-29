class AddPeopleContactInfo < ActiveRecord::Migration
  def self.up
    add_column :people, :website_one, :string
    add_column :people, :website_two, :string
    add_column :people, :webmail, :string
    add_column :people, :email, :string
  end

  def self.down
    remove_column :people, :website_one, :website_two, :webmail, :email
  end
end
