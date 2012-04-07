require 'spec_helper'

describe RecordsController do

  describe "#index" do
    before :each do
      @scope = mock("records scope")
      @scope.stub(:where => @scope)
      @scope.stub(:page  => @scope)
      @scope.stub(:desc  => @scope)
      Record.stub(:desc).and_return(@scope)
    end

    it "responds successfuly" do
      get 'index'
      response.should be_success
    end

    it "assigns some records" do
      get :index
      assigns(:records).should == @scope
    end

    context "when tags param given" do
      it "should filter records by tags" do
        tags = ['hello', 'world']
        @scope.should_receive(:where).with(:tags.in => tags)
        get :index, tags: tags
      end
    end
  end

  describe "GET 'show'" do
    it "should assign @record by id" do
      Record.should_receive(:find).with('kinda id').and_return('record')
      get :show, id: 'kinda id'
      assigns(:record).should == 'record'
    end

    context "when format is json" do
      let(:user)   { create :user }
      let(:record) { create :record }

      it "hits the record with current_user" do
        controller.stub(:current_user).and_return(user)
        Record.stub(:find).and_return(record)

        record.should_receive(:hit!).with(user)
        get :show, id: 'id', format: 'json'
      end
    end
  end

  describe "POST create" do
    it "should not verify authenticy token (we use API key here)" do
      pending
      controller.should_not_receive(:verify_authenticity_token)
      controller.stub(:create)
      post :create
    end
  end
end
