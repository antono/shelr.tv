require 'spec_helper'

describe Comment do

  subject { Factory.build :comment }

  it_behaves_like "editable with restrictions"
  it_behaves_like "editable by God"
  it_behaves_like "editable by Owner"

  describe ".for(commentable)" do
    it "should filter comments for given commentable" do
      commentable = Factory(:record)
      commentable.comments << Factory(:comment)
      Comment.for('record', commentable.id).should == commentable.comments
    end
  end

end
