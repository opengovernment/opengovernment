class Admin::TaggingsController < Admin::AdminController
  def destroy
    @taggable_type = params[:taggable_type]
    @taggables = taggables_for(@taggable_type)
    @tagging = ActsAsTaggableOn::Tagging.find(params[:id])
    @tagging.destroy
    respond_to { |format| format.js }
  end

  def create
    @taggable_type = params[:taggable_type]
    unless params[:taggables].blank?
      case @taggable_type
        when "subject"
          @subjects = params[:taggables].collect { |s| Subject.find(s) }
          @subjects.map do |subject|
            subject.issue_list << params[:tag]
            subject.save
          end
        when "category"
          @categories = params[:taggables].collect { |s| Category.find(s) }
          @categories.map do |kat|
            kat.issue_list << params[:tag]
            kat.save
          end
      end
    end

    @taggables = taggables_for(@taggable_type)

    respond_to do |format|
      format.js
    end
  end

  protected

  def taggables_for(taggable_type)
    case @taggable_type
      when "category"
        Category.all.paginate(:page => params[:page], :order => params[:order])
      when "subject"
        Subject.all.paginate(:page => params[:page], :order => params[:order])
    end
  end

end
