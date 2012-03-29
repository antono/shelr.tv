class CommentsController < ApplicationController

  COMMENTABLES = ['record', 'user']

  respond_to :html, :json

  def index
    @comments = Comment.for(params[:commentable], params[:commentable_id]).page(params[:page]).desc(:created_at)
    
    respond_with @comments
  end

  private

  def commentable
    @_commentable ||= commentable_class.find(params[:id])
  end

  def commentable_class
    if COMMENTABLES.include? params[:commentable]
      @_commentable_class ||= params[:commentable].classify.constantize
    end
  end
end
