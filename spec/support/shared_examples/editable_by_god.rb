shared_examples Traits::EditableByGod do

  describe "#editable_by?(user)" do
    context "when user is god?" do
      it "returns true" do
        god = mock_model(User, god?: true)
        subject.editable_by?(god).should be_true
      end
    end

    context "when user is not god?" do
      it "returns false" do
        god = mock_model(User, god?: false)
        subject.editable_by?(god).should be_false
      end
    end
  end
end
