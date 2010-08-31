class AddOfficialUrlToStates < ActiveRecord::Migration
  def self.up
    add_column :states, :official_url, :string
    
    states = YAML.load_file(File.join(Rails.root, 'lib/tasks/fixtures/states.yml'))
    states.each do |key, value|
      if s = State.find_by_abbrev(value['abbrev'])
        s.update_attributes(:official_url => value['official_url'])
      end
    end
    
  end

  def self.down
    remove_column :states, :official_url
  end
end
