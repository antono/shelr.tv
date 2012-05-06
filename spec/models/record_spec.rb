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
  its(:private)    { should == false     }
  its(:access_key) { should == ''        }

  describe "scope" do
    let!(:priv) { create(:record, private: true)  }
    let!(:publ) { create(:record, private: false) }

    describe ".publ" do
      it "finds public records" do
        Record.publ.all.should_not include priv
        Record.publ.all.should include publ
      end
    end

    describe ".priv" do
      it "returns private records" do
        Record.priv.all.should include priv
        Record.priv.all.should_not include publ
      end
    end
  end


  describe ".visible_by(user)" do
    let!(:owner) { create(:user) }
    let!(:other) { create(:user) }

    before do
      @private = 3.times.reduce([]) do
        create(:record, user: owner, private: true)
      end
      @public = create(:record, private: false, user: other)
    end

    context "when user is owner" do
      it "should include public records" do
        Record.visible_by(owner).all.should include @public
      end

      it "shoud include user's private records" do
        Record.visible_by(owner).all.should include @private
      end
    end

    context "when user is not owner" do
      it "shoud not include other user's private records" do
        Record.visible_by(other).all.should_not include @private
      end
    end

    context "when user is nil" do
      it "should include public" do
        Record.visible_by(nil).all.should include @public
      end

      it "should not include private" do
        Record.visible_by(nil).all.should_not include @private
      end
    end
  end

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

  describe "#vote!(direction, user)" do

    subject     { create :record }
    let(:voter) { create :user }

    context "when direction is :up" do
      it "increments reating" do
        lambda { subject.vote!(:up, voter) }.should change(subject.reload, :rating).by 1
      end

      it "adds voter to #upvoters" do
        subject.upvoters.should_not include(voter)
        subject.vote!(:up, voter)
        subject.upvoters.should include(voter)
      end

      context "and user is already voted up" do
        before :each do
          subject.vote!(:up, voter)
        end

        it "should not change rating" do
          -> { subject.vote!(:up, voter) }.should change(subject.reload, :rating).by 0
        end
      end

      context "and user is already voted down" do
        before :each do
          subject.vote!(:down, voter)
          subject.downvoters.should include voter
          subject.upvoters.should_not include voter
        end

        it "moves user from downvoters to upvoters" do
          subject.vote!(:up, voter)
          subject.downvoters.should_not include voter
          subject.upvoters.should include voter
        end

        it "it increments rating by +2" do
          -> { subject.vote!(:up, voter) }.should change(subject.reload, :rating).by +2
        end
      end
    end

    context "when direction is :down" do
      it "decrements rating" do
        lambda { subject.vote!(:down, voter) }.should change(subject.reload, :rating).by -1
      end

      it "adds voter to #downvoters" do
        subject.upvoters.should_not include(voter)
        subject.vote!(:up, voter)
        subject.upvoters.should include(voter)
      end

      context "and user is already voted down" do
        before :each do
          subject.vote!(:down, voter)
        end

        it "should not change rating" do
          -> { subject.vote!(:down, voter) }.should change(subject.reload, :rating).by 0
        end
      end

      context "and user is already voted up" do
        before :each do
          subject.vote!(:up, voter)
        end

        it "changes rating by -2" do
          -> { subject.vote!(:down, voter) }.should change(subject.reload, :rating).by -2
        end

        it "moves user from upvoters to downvoters" do
          subject.upvoters.should include voter
          subject.downvoters.should_not include voter
          subject.vote!(:down, voter)
          subject.upvoters.should_not include voter
          subject.downvoters.should include voter
        end
      end
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
    it "generated on save" do
      subject.description = "# Hello World"
      subject.description_html.should_not be_present
      subject.save
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
