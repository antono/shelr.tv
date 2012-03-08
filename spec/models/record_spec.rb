require 'spec_helper'

describe Record do

  describe "on create" do
    subject { Factory.build :record }

    it "should set licse to 'by-sa' before create" do
      subject.save
      subject.license.should == 'by-sa'
    end

    it "should set created_at and updated_at" do
      subject.save
      subject.created_at.should be_a(DateTime)
      subject.updated_at.should be_a(DateTime)
    end
  end

  describe "access" do
    let(:user) { Factory :user }

    describe "#editable_by?(user)" do
      it "should return true if user is owner" do
        subject.user = user
        subject.should be_editable_by(user)
      end

      it "should return true if user is god" do
        god = Factory :user, god: true
        subject.user = user
        subject.should be_editable_by(god)
      end

      it "should return false if user is not User" do
        subject.should_not be_editable_by(nil)
        subject.should_not be_editable_by(false)
        subject.should_not be_editable_by(Record)
      end

      it "should return false if user is not owner" do
        subject.user = user
        not_owner = Factory :user
        subject.should_not be_editable_by(not_owner)
      end
    end
  end

  describe "#size" do
    it "should return #columns x #rows as string" do
      subject.columns = 10
      subject.rows    = 20
      subject.size.should == "10x20"
    end
  end

  describe "#columns" do
    it "should return 80 if columns is blank" do
      subject.columns = nil
      subject.columns.should == 80
    end
  end

  describe "#rows" do
    it "should return 24  if rows is blank" do
      subject.rows = nil
      subject.rows.should == 24
    end
  end

  describe "#tags=(tags)" do
    it "should split tags with ',' and assign them" do
      subject.tags = "one, two"
      subject.read_attribute(:tags).should == ["one", "two"]
    end

    it "should strip tags" do
      subject.tags = "   one, two  "
      subject.read_attribute(:tags).should == ["one", "two"]
    end
  end

  describe "#title" do
    it "should return 'untitled' if attr is blank" do
      subject.title = nil
      subject.title.should == 'untitled'
    end
  end

  describe "#description_html" do
    it "should convert markdown from #description to html" do
      subject.description = "# Hello World"
      subject.description_html.should == "<h1>Hello World</h1>\n"
    end
  end
end
