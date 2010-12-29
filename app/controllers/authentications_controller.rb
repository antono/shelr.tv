class AuthenticationsController < ApplicationController
  def index
    if logged_in?
      @authentications = current_user.authentications 
    else
      redirect_to login_url
    end
  end

  def logout
    session.delete(:user_id)
    redirect_to '/'
  end

  def login
    redirect_to '/auth/twitter'
  end

  def create
    omniauth = request.env["omniauth.auth"]
    logger.debug(omniauth.to_yaml)
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      session[:user_id] = authentication.user_id
      if authentication.user.activated?
        flash[:notice] = "Signed in successfully."
        redirect_to user_path(authentication.user)
      else
        flash[:notice] = "Please fill Your profile to continue."
        redirect_to edit_user_path(authentication.user)
      end
    elsif current_user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      flash[:notice] = "Authentication successful."
      redirect_to authentications_url
    else
      user = User.new
      user.apply_omniauth(omniauth)
      if user.save
        session[:user_id] = user.id
        flash[:notice] = "Signed in successfully."
        redirect_to edit_user_path(user)
      else
        flash[:notice] = "Failed "
        redirect_to authentications_url
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
  end
end
