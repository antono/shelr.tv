class RecordsController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:create]

  respond_to :html, :json, :atom

  def index
    if params[:tags]
      @records = Record.desc(:created_at).where(:tags.in => params[:tags]).page(params[:page])
    else
      @records = Record.desc(:created_at).page(params[:page])
    end
    respond_with @records
  end

  def show
    @record = Record.find(params[:id])
    @record.hit!(current_user) if request.format.json?
    respond_with @record
  rescue Mongoid::Errors::DocumentNotFound
    render :no_such_record
  end

  def edit
    @record = Record.find(params[:id])
  end

  def create
    user = User.where(api_key: params[:api_key]).first if params[:api_key].present?
    user = User.where(nickname: 'Anonymous').first unless user

    record = Record.new(JSON.parse(params[:record]))
    # FIXME: wtf?
    record.user = user

    if record.save
      user.records << record
      user.save
      render json: { ok: true,  id: record.id.to_s, message: 'Record published!' }
    else
      render json: { ok: false, message: 'Cannot publish the record :(' }
    end
  rescue => e
    render json: { ok: false, message: "Cannot publish the record :(\n\n" + e.message }
  end

  def update
    @record = Record.find(params[:id])
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

  def search
    @records = Record.solr_search do
      fulltext params[:q]
      paginate page: params[:page] || 1
    end.results
    respond_with @records
  end
end
