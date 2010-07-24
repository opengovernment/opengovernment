class Admin::IssuesController < ApplicationController
  def index
    @issues = ActsAsTaggableOn::Tag.all
    @subjects = Subject.all.paginate(:page => params[:page], :order => params[:order])
    @categories = Category.all.paginate(:page => params[:page], :order => params[:order])
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
