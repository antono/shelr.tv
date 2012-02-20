class HomeController < ApplicationController
  def landing
    @records = Record.desc(:created_at).page(1).per(5)
  end

  def about
  end
end
