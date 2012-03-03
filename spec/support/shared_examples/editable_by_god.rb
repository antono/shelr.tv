shared_examples "editable by god" do

  describe "#editable_by?(user)" do
    context "when user is god?" do
      it "returns true" do
        god = Factory(:user, god: true)
        subject.editable_by?(god).should be_true
      end
    end

    context "when user is not god?" do
      it "returns false" do
        god = Factory(:user, god: false)
        subject.editable_by?(god).should be_false
      end
    end
  end
end
