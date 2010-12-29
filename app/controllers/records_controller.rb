class RecordsController < ApplicationController
  #before_filter :login_or_oauth_required, only: [:create, :update, :destroy, :new]
  respond_to :html, :json

  def index
    @records = Record.all
    respond_with @records
  end

  def show
    @record = Record.find(params[:id])
    respond_with @record
  end

  def new
  end

  def create
    record = Record.from_bundle(params)
    if record.save
      logger.debug(record)
    else
      logger.debug(record.errors)
    end
  end

  def update
  end

  def destroy
  end
end
