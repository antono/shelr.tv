class UsersController < ApplicationController

  def show
    @user = User.find(params[:id], include: :records)
  end

  def edit
    @user = current_user
  end

  def update
    current_user.update_attributes(params[:user])
    redirect_to current_user
  end
end
