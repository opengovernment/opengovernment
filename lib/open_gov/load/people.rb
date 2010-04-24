module OpenGov::Load::People
  def self.import!
    State.loadable.each do |state|
      import_one(state)
    end
  end

  def self.import_one(state)
    FiftyStates::Legislator.search(:state => state.abbrev).each do |fs_person|
      unless person = Person.find_by_fiftystates_id(fs_person.leg_id)
        person = Person.new(:fiftystates_id => fs_person.leg_id)
      end

      person.update_attributes!(
        :first_name => fs_person.first_name,
        :last_name => fs_person.last_name,
        :votesmart_id => fs_person.votesmart_id,
        :nimsp_candidate_id => fs_person.nimsp_candidate_id,
        :middle_name => fs_person.middle_name,
        :suffix => fs_person.suffix,
        :updated_at => fs_person.updated_at
      )
      
      person.save!

      fs_person.roles.each do |fs_role|

        if fs_role[:type] == FiftyStates::ROLE_MEMBER
          legislature = state.legislature

          case fs_role.chamber
          when FiftyStates::CHAMBER_UPPER
            chamber = legislature.upper_chamber
          when FiftyStates::CHAMBER_LOWER
            chamber = legislature.lower_chamber
          end

          district = chamber.districts.numbered(fs_role.district.to_s).first
          session = Session.find_by_legislature_id_and_name(state.legislature, fs_role.session)
          
          role = Role.find_or_initialize_by_district_id_and_chamber_id(district.id, chamber.id)
          
          role.update_attributes!(
            :person => person,
            :session => session,
            :start_date => Date.parse("#{session.start_year}-01-01").to_time,
            :end_date => Date.parse("#{session.end_year}-12-31").to_time,
            :party => fs_role.party
          )
        end
      end
    end
  end
end
