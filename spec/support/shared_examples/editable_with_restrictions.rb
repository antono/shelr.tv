shared_examples Traits::EditableWithRestrictions do

  it { should respond_to(:editable_by?) }

  describe "#editable_by?(user)" do
    context "when user is nil" do
      it "returns false" do
        subject.editable_by?(nil).should be_false
      end
    end
  end
end
