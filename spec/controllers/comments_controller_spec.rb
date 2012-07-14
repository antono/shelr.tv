require 'spec_helper'

describe CommentsController do

  describe "on GET index" do
    before do
      @scope = mock('comments scope')
      @scope.stub(:comments => @scope)
      @scope.stub(:page => @scope)
      @scope.stub(:desc => @scope)

      controller.stub(:commentable => @scope)
    end

    let(:record)  { create :record }

    it "paginates comments given params[page]" do
      @scope.should_receive(:page).with("1")
      get :index, record_id: record.id.to_s, page: 1
    end

    it "sorts comments by created_at" do
      @scope.should_receive(:desc).with(:created_at)
      get :index, record_id: record.id.to_s
    end
  end

  describe "POST create" do
    let!(:user)    { create :user }
    let!(:record)  { create :record  }

    before do
      controller.stub(:current_user => user)
    end

    it "creates new comment for given commentable" do
      expect {
        post :create, record_id: record.id.to_s, comment: { body: 'hello world' }
      }.to change(record.comments, :count).by 1
    end

    it "creates assigns comment to current user" do
      post :create, record_id: record.id.to_s, comment: { body: 'hello world' }
      record.comments.first.user.should == user
    end

    it "assigns new comment as @comment" do
      post :create, record_id: record.id.to_s, comment: { body: 'hello world' }
      assigns(:comment).should_not be_blank
    end

    it "renders @comment as json" do
      post :create, record_id: record.id.to_s, comment: { body: 'hello world' }
      lambda { JSON.parse(response.body) }.should_not raise_error
      JSON.parse(response.body)['body'].should_not be_blank
    end
  end

end
