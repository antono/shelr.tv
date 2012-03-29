require 'spec_helper'

describe CommentsController do

  describe "on GET index" do
    before do
      @scope = mock('comments scope')
      @scope.stub(:page => @scope)
      @scope.stub(:desc => @scope)
      Comment.stub(:for => @scope)
    end

    it "retreives comments for commentable" do
      Comment.should_receive(:for).with('record', '1')
      get :index, commentable: 'record', commentable_id: 1
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

end
