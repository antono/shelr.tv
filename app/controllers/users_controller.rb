class UsersController < ApplicationController


  def show
    @user = User.where(nickname: params[:id]).first
  end

  def edit
    @user = current_user
  end

  def update
    current_user.update_attributes(params[:user])
    redirect_to current_user
  end


  #
  # Session management
  #
  
  def logout
    session.delete(:user_id)
    redirect_to '/'
  end

  def login
    redirect_to '/auth/twitter'
  end

  def authenticate
    omniauth = request.env["omniauth.auth"]
    logger.debug(omniauth.to_yaml)
    user = User.where(twitter_id: omniauth['uid']).first
    if user
      flash[:notice] = "Signed in successfully."
      session[:user_id] = user.id.to_s
      redirect_to user_path(id: user.id.to_s)
    else
      user_info = omniauth['user_info']
      user = User.new(nickname: user_info['nickname'], twitter_id: omniauth['uid'])
      if user.save
        session[:user_id] = user.id.to_s
        flash[:notice] = "Signed in successfully."
        redirect_to edit_user_path(id: user.id.to_s)
      else
        flash[:notice] = "Failed "
        redirect_to root_url
      end
    end
  end
end
