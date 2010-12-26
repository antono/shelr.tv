class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def current_user
    return @user if @user
    if session[:user_id].blank?
      return false
    else
      return @user = User.find(session[:user_id])
    end
  end
end
