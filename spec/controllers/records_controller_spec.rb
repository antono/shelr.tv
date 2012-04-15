require 'spec_helper'

describe RecordsController do

  describe "GET /index" do
    before :each do
      @scope = mock("records scope")
      @scope.stub(:where       => @scope)
      @scope.stub(:page        => @scope)
      @scope.stub(:desc        => @scope)
      @scope.stub(:without     => @scope)
      @scope.stub(:priv        => @scope)
      @scope.stub(:publ        => @scope)
      @scope.stub(:visible_by  => @scope)
      Record.stub(:desc).and_return(@scope)
    end

    it "responds successfuly" do
      get 'index'
      response.should be_success
    end

    it "assigns some records" do
      get :index
      assigns(:records).should == @scope
    end

    it "does not fetch typestript and timing" do
      @scope.should_receive(:without).with(:typescript, :timing)
      get :index
    end

    it "should filter records for user" do
      user = mock_model(User)
      controller.stub(:current_user).and_return(user)
      @scope.should_receive(:visible_by).with(user)
      get :index
    end

    context "when tags param given" do
      it "should filter records by tags" do
        tags = ['hello', 'world']
        @scope.should_receive(:where).with(:tags.in => tags)
        get :index, tags: tags
      end
    end
  end

  describe "#find_record" do

    let(:priv) { create :record, private: true  }
    let(:publ) { create :record, private: false }

    context "when access_key given" do
      it "assigns private record" do
        get :show, id: priv.id, access_key: priv.access_key
        assigns(:record).should == priv
      end
    end

    context "when no access_key given" do
      before do
        controller.stub(:current_user).and_return(publ.user)
      end

      it "do not assign private record @record" do
        get :show, id: priv.id
        assigns(:record).should be_nil
      end

      it "assigns public @record by id" do
        get :show, id: publ.id
        assigns(:record).should == publ
      end

      context "when user is owner of private record" do
        before do
          controller.stub(:current_user).and_return(priv.user)
        end

        it "assigns private record as @record" do
          get :show, id: priv.id
          assigns(:record).should == priv
        end
      end
    end
  end

  describe "GET 'show'" do
    context "when no such record" do
      it "should render :no_such_record template" do
        record_id = create(:record).id.to_s
        Record.destroy_all
        get :show, id: record_id
        response.should render_template :no_such_record
      end
    end

    context "when format is json" do
      let(:user)   { create :user }
      let(:record) { create :record }

      it "hits the record with current_user" do
        controller.stub(:current_user).and_return(user)
        Record.stub_chain(:visible_by, :find).and_return(record)
        record.should_receive(:hit!).with(user)
        get :show, id: record.id.to_s, format: 'json'
      end
    end
  end

  describe "POST create" do
    it "should not verify authenticy token (we use API key here)" do
      pending
      controller.should_not_receive(:verify_authenticity_token)
      controller.stub(:create)
      post :create
    end
  end
end
