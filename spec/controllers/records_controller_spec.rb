require 'spec_helper'

describe RecordsController do

  describe "GET 'index'" do
    before :each do
      Record.stub_chain(:desc, :where, :page, :per)
      Record.stub_chain(:desc, :page, :per)
    end

    it "should be successful" do
      get 'index'
      response.should be_success
    end

    it "should respond to json, html and atom" do
      [:html, :json, :atom].each do |format|
        get :index, format: format
        response.should be_success
      end
    end

    it "should assign some records" do
      Record.stub_chain(:desc, :page, :per).and_return('records')
      get :index
      assigns(:records).should_not be_blank
      assigns(:records).should == 'records'
    end

    context "when tags param given" do
      it "should filter records by tags" do
        tags = ['hello', 'world']
        Record.desc.should_receive(:where).with(:tags.in => tags)
        get :index, tags: tags
      end
    end
  end

  describe "GET 'show'" do
    it "should assign @record by id" do
      Record.should_receive(:find).with('kinda id')
      get :show, id: 'kinda id'
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
