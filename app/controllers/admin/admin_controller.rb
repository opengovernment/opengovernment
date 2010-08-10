class Admin::AdminController < Admin::ApplicationController
  def index
    render :template => "admin/index"
  end
end
