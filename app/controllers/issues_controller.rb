class IssuesController < ApplicationController
  before_filter :get_issue, :only => [:show]

  def index
    @issues = ActsAsTaggableOn::Tag.all
  end

  def show
    @actions = Action.find_all_by_issue(@issue)
    @bills = Bill.find_all_by_issue(@issue)
    @sigs = SpecialInterestGroup.find_all_by_issue(@issue)

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
