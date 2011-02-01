class SubjectsController < SubdomainController
  before_filter :get_subject, :only => :show

  def index
    @min_bills = 1
    page = params[:page] || 1

    @subjects = Subject.for_sessions(@session.family)
    @letters = @subjects.select('upper(substring(subjects.name from 1 for 1)) as letter').group('upper(substring(subjects.name from 1 for 1))').map { |x| x.letter }

    @letter = params[:letter] || @letters.first

    @subjects = @subjects.select("distinct subjects.*").where(["upper(subjects.name) like ?", @letter + '%']).paginate(:page => params[:page])
  end

  def get_subject
    @subject = Subject.find(params[:id])
    @subject_bills = @subject.bills.where(["bills.session_id = ?", @session.id]).paginate(:page => params[:page])
    @subject || resource_not_found
  end  
end
