class Admin::IssuesController < Admin::AdminController
  def bills
    @tags = ActsAsTaggableOn::Tag.all
    @taggables = Subject.all.paginate(:page => params[:page], :order => params[:order])
    @title = "Bill Subjects"
    @taggable_type = "subject"
    render :template => 'admin/issues/tag'
  end

  def categories
    @tags = ActsAsTaggableOn::Tag.all
    @taggables = Category.all.paginate(:page => params[:page], :order => params[:order])
    @title = "VoteSmart Categories"
    @taggable_type = "category"
    render :template => 'admin/issues/tag'
  end

  def create
    new_tag = ActsAsTaggableOn::Tag.create(:name => params[:name])
    @tags = ActsAsTaggableOn::Tag.all

    respond_to { |format| format.js }
  end

  def destroy
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
    @tag.destroy
    @tags = ActsAsTaggableOn::Tag.all
    respond_to { |format| format.js }
  end

  def update
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
    @tag.update_attributes(:name => params[:name])
    @tags = ActsAsTaggableOn::Tag.all
    respond_to { |format| format.js }
  end
end
