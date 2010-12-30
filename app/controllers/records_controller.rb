class RecordsController < ApplicationController
  #before_filter :login_or_oauth_required, only: [:create, :update, :destroy, :new]
  respond_to :html, :json

  def index
    if params[:tags]
      @records = Record.where(:tags.in => params[:tags]).paginate(page: params[:page])
    else
      @records = Record.paginate(page: params[:page])
    end
    respond_with @records
  end

  def show
    @record = Record.criteria.id(params[:id]).first
    respond_with @record
  end

  def edit
    @record = Record.criteria.id(params[:id]).first
  end

  def create
    user = User.where(api_key: params[:api_key]).first unless params[:api_key].blank?
    user = User.where(nickname: 'Anonymous').first unless user

    record = Record.new(JSON.parse(params[:record]))

    if record.save
      user.records << record
      user.save
      render json: { ok: true,  id: record.id.to_s, message: 'Record published!' }
    else
      render json: { ok: false, message: 'Cannot publish record :(' }
    end
  end

  def update
    @record = Record.criteria.id(params[:id]).first
    if @record.editable_by?(current_user)
      if @record.update_attributes(params[:record])
        flash[:notice] = 'Record was succesfully updated.'
      else
        flash[:error] = 'You cannot edit this record.'
      end
    else
      flash[:error] = 'You cannot edit this record.'
    end
    redirect_to @record
  end

  def destroy
    @record = Record.find(params[:id])
    if @record.destroy
      flash[:notice] = "Shellcast was destroyed!"
      redirect_to records_path
    else
      flash[:notice] = "Shellcast was destroyed!"
      redirect_to @record
    end
  end
end
