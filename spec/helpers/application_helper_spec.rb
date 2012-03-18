require 'spec_helper'

describe ApplicationHelper do
  describe "#controller_and_action_class_names" do
    it "should return css class for controller and action" do
      helper.stub(:controller_name).and_return('test')
      helper.stub(:action_name).and_return('test')
      helper.controller_and_action_class_names
        .should == 'test-controller test-action'
    end
  end
end
