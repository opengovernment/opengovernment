module OpenGov
  class Committees < Resources
    class << self
      def import!
        State.loadable.each do |state|
          import_one(state)
        end
      end

      def import_one(state)
        committees = GovKit::VoteSmart::Committee.find_by_type_and_state(nil, state.abbrev)
        puts "Loading #{state.name} committees from VoteSmart..."

        # This should be an array of Committee objects.
        committees.committee.each do |committee|
          details = GovKit::VoteSmart::Committee.find(committee.committeeId)

          c = Committee.subclass_from_votesmart_type(committee.committeetypeId).find_or_initialize_by_votesmart_id(committee.committeeId)
          c.update_attributes!(
            :name => committee.name,
            :url => details.contact.url,
            :legislature_id => state.legislature.id,
            :votesmart_parent_id => (committee.parentId.to_i > 0 ? committee.parentId.to_i : nil),
            :votesmart_type_id => committee.committeetypeId
          )
        end
      end
    end
  end
end
