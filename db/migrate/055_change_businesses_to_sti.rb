class ChangeBusinessesToSti < ActiveRecord::Migration
  def self.up
    change_table(:businesses) do |t|
      t.rename :business_name, :name
      t.rename :nimsp_industry_code, :nimsp_code
      t.remove :industry_name
      t.remove :sector_name
      t.remove :nimsp_sector_code
      t.string :type
      t.string :ancestry
    end
  end

  def self.down
  end
end
