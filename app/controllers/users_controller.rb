class UsersController < ApplicationController

  respond_to :html, :json, :atom

  before_filter :login_required, except: [:show, :index]
  before_filter :find_user, only: [:show, :edit, :update]

  def index
    @users = UserDecorator.decorate(User.desc(:created_at).page(params[:page]).per(10))
  end

  def show
    @records = @user.records.desc(:created_at).visible_by(current_user).page(params[:page])
    respond_with @user
  end

  def update
    if @user.editable_by?(current_user)
      flash[:notice] = "Updated!"
      @user.update_attributes(params[:user])
    else
      flash[:error] = "Heh. No Way, man :)"
    end
    redirect_to @user
  end

  private

  def find_user
    @user = UserDecorator.find(params[:id])
  end
end
