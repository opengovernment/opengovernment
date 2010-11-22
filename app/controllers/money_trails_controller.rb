class MoneyTrailsController < ApplicationController
  before_filter :get_state
  before_filter :get_industry, :only => [:show]

  def index
    # We call .all here so we can execute the query now, due to a 
    # Rails bug with .count and .size
    @sectors = Sector.aggregates_for_state(@state.id).all
  end

  def show
    @contributions = Contribution.find_by_sql([%q{SELECT contributions.contributor_name, sum(contributions.amount) as amount FROM "contributions" INNER JOIN "corporate_entities" ON "contributions".business_id = "corporate_entities".id WHERE (("corporate_entities".industry_id = ?) AND (("corporate_entities"."type" = 'Business'))) AND ("contributions"."state_id" = ?) GROUP BY contributions.contributor_name ORDER BY amount desc LIMIT 20}, @industry.id, @state.id])
    
    @recipients = Contribution.find_by_sql([%q{SELECT contributions.person_id, sum(contributions.amount) as amount FROM "contributions" INNER JOIN "corporate_entities" ON "contributions".business_id = "corporate_entities".id WHERE (("corporate_entities".industry_id = ?) AND (("corporate_entities"."type" = 'Business'))) AND ("contributions"."state_id" = ?) GROUP BY contributions.person_id ORDER BY amount desc LIMIT 20}, @industry.id, @state.id])

    # TODO: These -should- work and did work, but are broken in Rails 3.0.3
    # @contributions = @industry.contributions.for_state(@state.id).grouped_by_name.limit(20).all
    # @recipients = @industry.contributions.for_state(@state.id).grouped_by_recipient.limit(20).all
  end

  protected
  def get_industry
    @industry = Industry.find(params[:id])
  end
end
