class AdminController < ApplicationController
  protect_from_forgery with: :exception

  before_action :authenticate_user!


  layout "admin"

  protected

  def require_admin!
    unless current_user.is_admin?
      flash[:alert] = "You have no permission"
      redirect_to root_path
    end
  end

  def require_editor!
    unless current_user.is_editor?
      flash[:alert] = "You have no permission"
      redirect_to root_path
    end
  end

end
