shared_examples Traits::EditableByOwner do

  its(:owner) { should_not be_blank }

  describe "#editable_by?(user)" do
    context "when user is subject.owner" do
      it "returns true" do
        subject.editable_by?(subject.owner).should be_true
      end
    end

    context "when user is NOT subject.owner" do
      it "returns false" do
        other_user = Factory.build(subject.class.to_s.underscore.to_sym)
        subject.editable_by?(other_user).should be_false
      end
    end
  end
end
