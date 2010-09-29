class Admin::TaggingsController < Admin::AdminController
  def destroy
    @taggable_type = params[:taggable_type]
    @tagging = ActsAsTaggableOn::Tagging.find(params[:id])

    @taggable_ids = @tagging.taggable_id
    @taggables = taggables_for(@taggable_type)
    @tagging.destroy

    respond_to do |format|
      format.js do
        render :template => 'admin/taggings/refresh'
      end
    end
  end

  def create
    @taggable_type = params[:taggable_type]
    @taggable_ids = params[:taggables]

    unless @taggable_ids.blank?
      @taggables = taggables_for(@taggable_type)

      @taggables.map do |item|
        item.issue_list << params[:tag]
        item.save
      end
    end

    respond_to do |format|
      format.js do
        render :template => 'admin/taggings/refresh'
      end
    end
  end

  protected

  def taggables_for(taggable_type)
    case taggable_type
      when "subject"
        Subject.where(:id => @taggable_ids)
      when "category"
        Category.where(:id => @taggable_ids)
    end
  end

end
