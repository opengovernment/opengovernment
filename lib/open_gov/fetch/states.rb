module OpenGov::Fetch::States
  FIFTYSTATES_URL = 'http://fiftystates-dev.sunlightlabs.com/api/'
  class << self
    def process
      FileUtils.mkdir_p(STATES_DIR)
      Dir.chdir(STATES_DIR)

      (State.pending | State.supported).each do |state|
        process_one(state)
      end
    end

    def process_one(state)
      if fs_state = FiftyStates::State.get(state.abbrev)
        if leg = Legislature.find(:first, :conditions => {:state_id => state.id})
          leg = Legislature.create!(
            :name => fs_state.legislature_name,
            :upper_chamber_name => fs_state.upper_chamber_name,
            :lower_chamber_name => fs_state.lower_chamber_name,
            :upper_chamber_title => fs_state.upper_chamber_title,
            :lower_chamber_title => fs_state.lower_chamber_title,
            :upper_chamber_term => fs_state.upper_chamber_term,
            :lower_chamber_term => fs_state.lower_chamber_term,
            :state_id => state.id
          )
        
          fs_state.sessions.each do |session|
          
          end
        end
      end
    end
  end

end
