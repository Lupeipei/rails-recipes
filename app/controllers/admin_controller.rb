class AdminController < ApplicationController
  protect_from_forgery with: :exception

  before_action :authenticate_user!


  layout "admin"

  protected

  def require_admin!
    if current_user.role != "admin"
      flash[:alert] = "You have no permission"
      redirect_to root_path
    end
  end

  def require_editor!
    if current_user.role != "editor" && current_user.role != "admin"
      flash[:alert] = "You have no permission"
      redirect_to root_path
    end
  end

end
