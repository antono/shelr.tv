shared_examples "editable by owner" do

  its(:owner) { should_not be_blank }

  describe "#editable_by?(user)" do
    context "when user == subject.owner" do
      it "returns true" do
        subject.editable_by?(subject.owner).should be_true
      end
    end
  end
end
