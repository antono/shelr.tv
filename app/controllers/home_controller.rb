class HomeController < ApplicationController
  def landing
    @records = Record.desc(:created_at).page(1)
  end

  def about
  end
end
