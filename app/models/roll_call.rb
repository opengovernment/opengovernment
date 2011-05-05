class RollCall < ActiveRecord::Base
  belongs_to :vote
  belongs_to :person
  has_and_belongs_to_many :roles, :join_table => "v_roll_call_roles", :readonly => true
  
  def as_json(opts = {})
    default_opts = {:except => [:person_id, :id] }
    super(default_opts.merge(opts))
  end
end
