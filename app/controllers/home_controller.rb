class HomeController < ApplicationController
  respond_to :html, :xml

  def landing
    @records = Record.desc(:created_at).page(1)
  end

  def about
  end

  def opensearch
    response.headers["Content-Type"] = 'application/opensearchdescription+xml'
    render :layout => false
  end

  def dashboard
    if logged_in?
      @comments = current_user.comments_for_records(params[:page])
    else
      redirect_to records_path
    end
  end
end
