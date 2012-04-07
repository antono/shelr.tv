require 'spec_helper'

describe Record do

  subject { build :record }

  it_behaves_like "editable with restrictions"
  it_behaves_like "editable by God"
  it_behaves_like "editable by Owner"

  its(:owner)      { should_not be_blank }
  its(:comments)   { should == []        }
  its(:viewers)    { should be_empty     }
  its(:hits)       { should == 0         }

  describe "on create" do
    before(:each) { subject.should be_new_record }

    it "should set licse to 'by-sa' before create" do
      subject.save
      subject.license.should == 'by-sa'
    end

    it "should set created_at and updated_at" do
      subject.save
      subject.created_at.should be_a(DateTime)
      subject.updated_at.should be_a(DateTime)
    end

    it "validates presence of user" do
      subject.user = nil
      subject.save.should be_false
      subject.user = create :user
      subject.save.should be_true
    end
  end

  describe "#size" do
    it "should return #columns x #rows as string" do
      subject.columns = 10
      subject.rows = 20
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

  describe "#hit!(user)" do
    let(:subject) { create :record }

    context "when user is not nil" do
      let(:user) { create :user }

      it "adds user to viewers" do
        subject.viewers.should_not include(user)
        subject.hit!(user)
        subject.viewers.should include(user)
      end

      it "saves the record" do
        subject.viewers.should be_empty
        subject.hit!(user)
        subject.reload.viewers.should_not be_empty
      end

      it "does not add user twice" do
        subject.viewers.should be_empty
        subject.hit!(user)
        subject.hit!(user)
        subject.reload.viewers.count.should == 1
      end
    end

    context "when user is nil" do
      it "ircreases hits count" do
        expect { subject.hit! }.to change(subject, :hits).by(1)
      end
    end
  end

  describe "#views(type)" do
    subject { create :record }

    before :each do
      subject.viewers << create(:user)
      subject.viewers << create(:user)
      subject.hits = 10
      subject.save
    end

    context "when type is :anonymous" do
      it "returns hit count" do
        subject.views(:anonymous).should == 10
      end
    end

    context "when type is :registered" do
      it "returns viewers count" do
        subject.views(:registered).should == 2
      end
    end

    context "when type is :all" do
      it "returns summary count" do
        subject.views(:all).should == 12
      end
    end
  end
end
