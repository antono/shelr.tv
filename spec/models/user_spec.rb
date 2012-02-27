require 'spec_helper'

describe User do

  describe "#nickname" do
    it "should be renameme if nickname blank" do
      user = User.new(nickname: '')
      user.save.should be_true
      user.nickname.should == 'noname'
    end
  end
end
