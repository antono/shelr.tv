require 'spec_helper'

describe CommentsController do
  before do
    @scope = mock('comments scope')
    controller.stub(:commentable => @scope)
  end


  describe "on GET index" do
    before do
      @scope.stub(:comments => @scope)
      @scope.stub(:page => @scope)
      @scope.stub(:desc => @scope)
    end

    it "paginates comments given params[page]" do
      @scope.should_receive(:page).with("1")
      get :index, page: 1
    end

    it "sorts comments by created_at" do
      @scope.should_receive(:desc).with(:created_at)
      get :index
    end
  end

  describe "POST create" do
    let(:user) { Factory(:user) }
    let(:commentable) { Factory(:record) }
    let(:comment) { Factory.build(:comment) }

    before do
      controller.stub(:commentable => commentable)
      controller.stub(:current_user => user)
    end

    it "creates new comment for given commentable" do
      commentable.comments.should_receive(:build)
        .with({ "body" => 'hello world' })
        .and_return(comment)
      post :create, { comment: { body: 'hello world' } }
    end

    it "creates assigns comment to current user" do
      post :create, { comment: { body: 'hello world' } }
      commentable.comments.first.user.should == user
    end

    it "assigns new comment as @comment" do
      post :create, { comment: { body: 'hello world' } }
      assigns(:comment).should_not be_blank
    end

    it "renders @comment as json" do
      post :create, { comment: { body: 'hello world' } }
      lambda { JSON.parse(response.body) }.should_not raise_error
      JSON.parse(response.body)['body'].should_not be_blank
    end
  end

end
