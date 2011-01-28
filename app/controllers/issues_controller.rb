class IssuesController < SubdomainController
  before_filter :get_issue, :only => [:show]

  def index
    @min_bills = 1
    @subjects = Subject.for_session(@session).order("subjects.name").with_bill_count.having(["count(bills_subjects.id) > ?", @min_bills]).limit(100)

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
    @actions = Action.by_state_and_issue(@state.id, @issue)
    @bills = Bill.by_state_and_issue(@state.id, @issue)
    @sigs = SpecialInterestGroup.by_state_and_issue(@state.id, @issue)

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
