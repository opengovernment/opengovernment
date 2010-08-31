class Admin::HomeController < Admin::AdminController
  def index
    render :template => "admin/index"
  end
end
