class IssuesController < ApplicationController
  before_filter :get_issue, :only => [:show]

  def index
    @issues = ActsAsTaggableOn::Tag.all
  end

  def show
    @actions = Action.find_by_sql(["select * from v_tagged_bill_actions
        where kind <> 'other' and kind is not null and tag_name = ? order by date desc", @issue.name])

    categories = Category.tagged_with(@issue.name)
    @sigs = categories.collect(&:special_interest_groups).flatten

    respond_to do |format|
      format.atom
      format.html
    end
  end

  protected
  def get_issue
    @issue = ActsAsTaggableOn::Tag.find_by_param(params[:id])
    @issue || resource_not_found
  end
end
