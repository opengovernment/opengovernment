class IssuesController < ApplicationController
  before_filter :get_issue, :only => [:show]

  def index
    @issues = ActsAsTaggableOn::Tag.all
  end

  def show
    subjects = Subject.tagged_with(@issue.name)
    @bills = subjects.collect(&:bills).flatten

    categories = Category.tagged_with(@issue.name)
    @sigs = categories.collect(&:special_interest_groups).flatten
  end

  protected
  def get_issue
    @issue = ActsAsTaggableOn::Tag.find_by_param(params[:id])
    @issue || resource_not_found
  end
end
