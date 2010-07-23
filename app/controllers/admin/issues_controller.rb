class Admin::IssuesController < ApplicationController
  def index
    @issues = ActsAsTaggableOn::Tag.all
  end

  def create
    new_tag = ActsAsTaggableOn::Tag.create(:name => params[:name])
    @issues = ActsAsTaggableOn::Tag.all

    respond_to do |format|
      format.js
    end
  end

  def destory
    @issues = Subject.tag_counts_on(:issues) * 2

    respond_to do |format|
      format.js
    end
  end
end
