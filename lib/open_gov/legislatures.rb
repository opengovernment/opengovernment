module OpenGov
  class Legislatures < Resources
    def self.import!
      State.loadable.each do |state|
        import_one(state)
      end
    end

    def self.import_one(state)
      puts "Importing legislature & sessions for #{state.abbrev}"
      if fs_state = GovKit::OpenStates::State.find_by_abbreviation(state.abbrev)
        leg = Legislature.find_or_create_by_state_id(state.id)

        leg.update_attributes!(
          :name => fs_state.legislature_name
        )

        ['UpperChamber', 'LowerChamber'].each do |c|
          field_prefix = c.to_s.underscore + "_"

          chamber = c.constantize.find_or_create_by_legislature_id(leg.id)

          chamber.update_attributes!(
            :name => fs_state[field_prefix + "name"],
            :title => fs_state[field_prefix + "title"],
            :term_length => fs_state[field_prefix + "term"]
          )
        end

        fs_state.terms.each do |t|
          @session = Session.find_or_create_by_legislature_id_and_name(leg.id, t.name)

          @session.update_attributes!(
            :start_year => t.start_year,
            :end_year => t.end_year
          )

#          @session.children.destroy_all

          t.sessions.each do |s|
            next if s == @session.name
            sub_session = Session.find_or_create_by_legislature_id_and_name(leg.id, s)
            sub_session.update_attributes!(
              :start_year => t.start_year,
              :end_year => t.end_year,
              :parent_id => @session.id
            )
          end
        end

      end
    end
  end
end
