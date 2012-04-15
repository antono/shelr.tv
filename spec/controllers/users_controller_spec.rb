require 'spec_helper'

describe UsersController do

  let(:user) { create(:user) }

  describe "GET show" do
    before :each do
      user.records << create(:record, private: false)
      user.records << create(:record, private: true)
    end

    it "assigns records for given user" do
      get :show, id: user.id.to_s
      assigns(:records).should_not be_blank
    end

    it "assigns ony visible records" do
      get :show, id: user.id.to_s
      assigns(:records).all.count.should == 1
      assigns(:records).all.should include(user.records.publ.first)
    end
  end
end
