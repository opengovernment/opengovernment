class Admin::IssuesController < ApplicationController
  def bills
    @tags = ActsAsTaggableOn::Tag.all
    @taggings = Subject.all.paginate(:page => params[:page], :order => params[:order])
  end

  def categories
    @tags = ActsAsTaggableOn::Tag.all
    @taggings = Category.all.paginate(:page => params[:page], :order => params[:order])
  end

  def create
    new_tag = ActsAsTaggableOn::Tag.create(:name => params[:name])
    @tags = ActsAsTaggableOn::Tag.all

    respond_to { |format| format.js }
  end

  def destory
    @issues = Subject.tag_counts_on(:issues) * 2
    respond_to { |format| format.js }
  end

  def update
    @tagging_type = params[:tagging_type]
    unless params[:taggings].blank?
      case @tagging_type
        when "subject"
          @subjects = params[:taggings].collect { |s| Subject.find(s) }
          @subjects.map do |subject|
            subject.issue_list << params[:tag]
            subject.save
          end
        when "category"
          @categories = params[:taggings].collect { |s| Category.find(s) }
          @categories.map do |kat|
            kat.issue_list << params[:tag]
            kat.save
          end
      end
    end

    @taggings =
      case @tagging_type
        when "category"
          Category.all.paginate(:page => params[:page], :order => params[:order])
        when "subject"
          Subject.all.paginate(:page => params[:page], :order => params[:order])
      end

    respond_to do |format|
      format.js
    end
  end
end
