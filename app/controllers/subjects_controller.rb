class SubjectsController < ApplicationController
  before_filter :get_state
  before_filter :get_subject, :only => :show

  def index
    @min_bills = 10
    letter = params[:letter] || 'A'
    page = params[:page] || 1
    
    if params[:all]
      @subjects = Subject.for_state(@state)
    else
      @subjects = Subject.for_state(@state).with_bill_count.having(["count(bills_subjects.id) > ?", @min_bills])
    end
    
    @subjects = @subjects.where(["upper(subjects.name) like ?", letter + '%']).paginate(:page => params[:page])
  end

  def get_subject
    @subject = Subject.find(params[:id])
    @subject_bills = @subject.bills.paginate(:page => params[:page])
    @subject || resource_not_found
  end  
end
