class HomeController < ApplicationController
  respond_to :html, :xml

  def landing
    @records = Record.desc(:created_at).page(1)
  end

  def opensearch
    response.headers["Content-Type"] = 'application/opensearchdescription+xml'
    render :layout => false
  end
end
