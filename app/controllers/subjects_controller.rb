class SubjectsController < ApplicationController
  before_filter :get_state
  before_filter :get_subject, :only => :show

  def index
    @min_bills = 4
    page = params[:page] || 1
    
    if params[:all]
      @subjects = Subject.for_state(@state)
      @letters = @subjects.select('upper(substring(subjects.name from 1 for 1)) as letter').group('upper(substring(subjects.name from 1 for 1))').map { |x| x.letter }
    else
      @subjects = Subject.for_state(@state).with_bill_count.having(["count(bills.id) > ?", @min_bills])
      @letters = Subject.find_by_sql(["
          SELECT
            letter from (
              SELECT upper(substring(subjects.name from 1 for 1)) as letter,
                subjects.*,
                count(bills.id)
              FROM
                subjects
                inner join bills_subjects on subjects.id = bills_subjects.subject_id
                inner join bills on bills.id = bills_subjects.bill_id
              WHERE bills.state_id = ?
              GROUP BY upper(substring(subjects.name from 1 for 1)), subjects.id, subjects.name, subjects.code, subjects.created_at, subjects.updated_at HAVING count(bills.id) > ?
            ) popular_subjects
          GROUP BY letter", @state.id, @min_bills]).map { |x| x.letter }
    end

    @letter = params[:letter] || @letters.first

    @subjects = @subjects.where(["upper(subjects.name) like ?", @letter + '%']).paginate(:page => params[:page])
  end

  def get_subject
    @subject = Subject.find(params[:id])
    @subject_bills = @subject.bills.paginate(:page => params[:page])
    @subject || resource_not_found
  end  
end
