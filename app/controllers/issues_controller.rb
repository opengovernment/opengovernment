class IssuesController < ApplicationController
  before_filter :get_issue, :only => [:show]

  def index
    respond_to do |format|
      @issues = ActsAsTaggableOn::Tag.all
      format.js do
        @issues = case params[:sort]
          when "name"
            ActsAsTaggableOn::Tag.order("name asc")
          when "bills"
            ActsAsTaggableOn::Tag.order("name asc")
          when "views"
            ActsAsTaggableOn::Tag.find(Page.most_viewed('Issue').collect(&:og_object_id))
          else
            @issues
        end
      end
      format.html
    end
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
