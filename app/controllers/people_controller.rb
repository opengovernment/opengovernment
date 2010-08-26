class PeopleController < ApplicationController
  before_filter :find_person, :except => [:index]
  before_filter :get_state

  # /states/texas/people
  def index
  end

  def votes
    @roll_calls = RollCall.paginate(:conditions => {:person_id => @person.id}, :include => {:vote => :bill}, :order => "votes.date desc", :page => params[:page])
  end

  def sponsored_bills
    @sponsorships = Sponsorship.find_all_by_sponsor_id(@person.id, :include => [:bill]).paginate(:page => params[:page])
  end

  # /people/1
  def show
   # add_breadcrumb @person.full_name, person_path(@person), :class => "person #{@person.gender_class}"
   respond_to do |format|
     format.js
     format.atom do
       
       render :template => 'shared/actions'
     end
     format.html do
       @latest_votes = @person.votes.latest
       @latest_roll_calls = @person.roll_calls.find_all_by_vote_id(@latest_votes)
     end
   end
  end

  protected
  def find_person
    @person = Person.find(params[:id])
    @person || resource_not_found
  end
  
end
