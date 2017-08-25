class UsersController < ApplicationController

  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to edit_user_path, notice: "updated"
    else
      render :edit
    end
  end

  protected

  def user_params
    params.require(:user).permit(:time_zone)
  end
end
