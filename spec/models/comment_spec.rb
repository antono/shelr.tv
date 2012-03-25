require 'spec_helper'

describe Comment do

  subject { Factory.build :comment }

  it_should_behave_like Traits::EditableWithRestrictions
  it_should_behave_like Traits::EditableByGod
  it_should_behave_like Traits::EditableByOwner

end
