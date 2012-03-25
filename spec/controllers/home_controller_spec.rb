require 'spec_helper'

describe HomeController do
  describe "GET about" do
    it "should render about page" do
      get :about
      response.should render_template('home/about')
    end
  end

  describe "GET landing" do
    it "should assign records for feed" do
      get :landing
      assigns(:records).should_not be_blank
    end
  end
end
