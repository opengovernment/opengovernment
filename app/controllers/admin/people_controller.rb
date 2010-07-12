class Admin::PeopleController < Admin::ApplicationController
  before_filter :find_person, :only => [:edit, :update]

  def update
    if @person.update_attributes(params[:person])
      flash[:notice] = "Person updated successfully."
      redirect_to(admin_states_url)
    else
      render :action => :edit
    end
  end

  protected
  def find_person
    @person = Person.find(params[:id])
    @person || resource_not_found
  end
end
