require 'spec_helper'

describe User do

  describe "on create" do
    it "should generate api key" do
      subject.should_receive(:generate_api_key)
      subject.save
    end

    it "should be renameme if nickname blank" do
      subject.should_receive(:maybe_assign_nickname_placeholder)
      subject.save
    end
  end

  describe "#maybe_assign_nickname_placeholder" do
    it "should change blank nickname to 'noname'" do
      subject.nickname = ''
      subject.save.should be_true
      subject.nickname.should == 'noname'
    end
  end

  describe "#generate_api_key" do
    it "should assign random md5 hash to #api_key" do
      subject.api_key.should be_blank
      subject.generate_api_key
      subject.api_key.should_not be_blank
    end

    it "should assign random md5 hash to #api_key" do
      subject.should be_new_record
      subject.generate_api_key!
      subject.should_not be_new_record
    end
  end
end
