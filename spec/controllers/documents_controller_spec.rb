require File.dirname(__FILE__) + '/../spec_helper'

# This is one of the automatically detected Controller, so we have to define it here
# It is an example how every child class of ManageResourceController::Base should behave.
class DocumentsController < ManageResourceController::Base; end

describe DocumentsController do
  it "should be a ManageResourceController" do
    controller.should be_a(ManageResourceController::Base)
  end

  it "should manage Documents" do
    controller.send(:model).should == Document
  end

  it "should manage translatable Docoments" do
    controller.send(:model).should be_acts_as(:translated)
  end

  describe "route recognition" do

    it "should generate params { :controller => 'documents', action => 'index' } from GET /manage/documents" do
      params_from(:get, "/manage/documents").should == {:controller => "documents", :action => "index"}
    end
  
    it "should generate params { :controller => 'documents', action => 'new' } from GET /manage/documents/new" do
      params_from(:get, "/manage/documents/new").should == {:controller => "documents", :action => "new"}
    end
  
    it "should generate params { :controller => 'documents', action => 'create' } from POST /manage/documents" do
      params_from(:post, "/manage/documents").should == {:controller => "documents", :action => "create"}
    end
  
    it "should generate params { :controller => 'documents', action => 'show', id => '1' } from GET /manage/documents/1" do
      params_from(:get, "/manage/documents/1").should == {:controller => "documents", :action => "show", :id => "1"}
    end

    it "should generate params { :controller => 'documents', action => 'show', id => '1', :locale => 'de' } from GET /de/manage/documents/1" do
      params_from(:get, "/de/manage/documents/1").should == {:controller => "documents", :action => "show", :id => "1", :locale => 'de'}
    end
  
  
    it "should generate params { :controller => 'documents', action => 'edit', id => '1' } from GET /manage/documents/1;edit" do
      params_from(:get, "/manage/documents/1/edit").should == {:controller => "documents", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'documents', action => 'update', id => '1' } from PUT /manage/documents/1" do
      params_from(:put, "/manage/documents/1").should == {:controller => "documents", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'documents', action => 'destroy', id => '1' } from DELETE /manage/documents/1" do
      params_from(:delete, "/manage/documents/1").should == {:controller => "documents", :action => "destroy", :id => "1"}
    end
    
  end

  describe "route generation" do

    it "should map { :controller => 'documents', :action => 'index' } to /manage/documents" do
      route_for(:controller => "documents", :action => "index").should == "/manage/documents"
    end
  
    it "should map { :controller => 'documents', :action => 'new' } to /manage/documents/new" do
      route_for(:controller => "documents", :action => "new").should == "/manage/documents/new"
    end
  
    it "should map { :controller => 'documents', :action => 'show', :id => 1 } to /manage/documents/1" do
      route_for(:controller => "documents", :action => "show", :id => '1').should == "/manage/documents/1"
    end
  
    it "should map { :controller => 'documents', :action => 'edit', :id => 1 } to /manage/documents/1/edit" do
      route_for(:controller => "documents", :action => "edit", :id => '1').should == "/manage/documents/1/edit"
    end

    it "should map document_path(document) to /en/manage/documents/:id" do
      @document = Factory(:document)
      document_path(@document).should =~ %r~^/en/manage/documents/document-\d+~ 
    end
    
  end

  describe "every request", :shared => true do
    it "should succeed" do
      do_request
      response.should be_success
    end
    it "should prepare clipboard" do
      clipboard = mock_model(Clipboard)
      clipboard.stub!(:<<).and_return(true)
      ::Clipboard.should_receive(:new).and_return( clipboard )
      do_request
    end

    it "should set context page from request header" do
      @request.env['Tirade-Page'] = 23
      Page.should_receive(:find_by_id).with(23).and_return( Factory(:page) )
      do_request
    end

  end

  describe "every request with form", :shared => true do
    it "should set the formbuilder" do
      ActionView::Base.should_receive(:default_form_builder=).with(ToolboxFormBuilder)
      do_request
    end
  end

  describe "every request that sets flash messages", :shared => true do
    it "should render flash messages as gritter notifications" do
      do_request
      response.body.should =~ %r~\$\.gritter\.add\(\{.*\}\)~
    end
  end

  describe "by AJAX" do

    before( :each ) do
      login_with_group :admin_documents
      login_standard
      Document.destroy_all
      @document = Factory.create(:document)
      @documents = [@document]
      5.times { @documents << Factory.create(:document) }
    end

    it "should have some Documents provided" do
      Document.should have_at_least(6).records
    end

    it "should allow all access" do
      allowed_actions.should == all_actions
    end


    describe "get /index without any params" do
      def do_request
        get :index, :format => 'js'
      end

      it_should_behave_like 'every request'

      it "should set assigns" do
        do_request
        assigns[:collection].should_not be_blank
        assigns[:documents].should_not be_blank
      end

      it "should render a list" do
        do_request
        response.should render_template('_list.html.erb')
      end

      it "should push the list into toolbox" do
        do_request
        response.should push_frame
      end

      it "should set the toolbox header" do
        do_request
        response.should set_toolbox_header('Documents')
      end

    end

    describe "get /index from livesearch" do
      def do_request(term='lot')
        get :index, :format => 'js', :search => {:term => term}
      end

      it_should_behave_like 'every request'

      it "should set assigns" do
        do_request
        assigns[:collection].should_not be_blank
        assigns[:documents].should_not be_blank
      end

      it "should render a list" do
        do_request
        response.should render_template('contents/_list_item.erb')
      end

      it "should pupulate a div.search_results" do
        do_request
        unescape_rjs(response.body).should have_text(%r~Toolbox.last\(\).find\("div.search_results.documents"\).html\(~)
      end

    end

    describe "get /index for refresh" do
      def do_request(term='lot')
        @request.env['Tirade-Frame'] = '2342'
        get :index, :format => 'js', :refresh => 1
      end

      it_should_behave_like 'every request'

      it "should set assigns" do
        do_request
        assigns[:collection].should_not be_blank
        assigns[:documents].should_not be_blank
      end

      it "should render a list" do
        do_request
        response.should render_template('_list.html.erb')
      end

      it "should update the supplied frame" do
        do_request
        unescape_rjs(response.body).should have_text(%r~Toolbox.frames\("#frame_2342"\).html\(~)
      end

    end
    
    describe "get /new" do
      def do_request
        get :new, :format => 'js'
      end

      it_should_behave_like 'every request'
      it_should_behave_like 'every request with form'

      it "should render the contents form (document has no own yet )" do
        do_request
        response.should render_template('documents/_form.html.erb')
      end

    end

    describe "creating a valid Document" do

      def do_request
        post :create, :document => Factory.attributes_for(:document), :format => 'js'
      end

      it_should_behave_like 'every request'
      it_should_behave_like 'every request with form'
      it_should_behave_like 'every request that sets flash messages'

      it "should save the Document" do
        lambda { do_request }.should change(Document,:count).by(1)
      end

      it "should update the 'new' (current) frame with 'show'" do
        @request.env['Tirade-Frame'] = '2342'
        do_request
        response.should render_template('documents/_show.html.erb')
        response.should select_toolbox_frame('#frame_2342')
      end

      it "should add the Document to the clipboard" do
        clipboard = mock_model(::Clipboard)
        ::Clipboard.stub!(:new).and_return(clipboard)
        clipboard.stub!(:<<).with(kind_of(Document)).and_return(true)
        do_request
        response.body.should =~ /Toolbox.setClipboard/
      end

    end

    describe "trying to create a Document with invalid attributes" do

      def do_request
        post :create, :document => Factory.attributes_for(:document), :format => 'js'
      end

      it_should_behave_like 'every request'
      it_should_behave_like 'every request with form'
      it_should_behave_like 'every request that sets flash messages'
      
      before( :each ) do
        @new_document = Factory.build :document
        @new_document.stub!(:valid?).and_return(false)
        Document.stub!(:new).and_return(@new_document)
      end

      it "should not save the Document" do
        lambda { do_request }.should_not change(Document,:count)
      end

      it "should rerender the form" do
        do_request
        response.should render_template('documents/_form.html.erb')
      end

      it "should show validation errors" do
        do_request
        response.should set_notification('Failed to create Document')
      end

      it "should not add the unsaved Document to the clipboard" do
        clipboard = mock_model(::Clipboard)
        ::Clipboard.stub!(:new).and_return(clipboard)
        clipboard.should_not_receive(:<<)
        do_request
      end

    end

    describe "get /show" do

      def do_request
        get :show, :id => @document.to_param, :format => 'js'
      end

      it_should_behave_like 'every request'

      it "should render show partial" do
        do_request
        response.should render_template('documents/_show.html.erb')
      end

    end

    describe "get /show for refresh" do
      def do_request(term='lot')
        @request.env['Tirade-Frame'] = '2342'
        get :show, :id => @document.to_param, :format => 'js', :refresh => 1
      end

      it_should_behave_like 'every request'

      it "should render show partial" do
        do_request
        response.should render_template('documents/_show.html.erb')
      end

      it "should update the supplied frame" do
        do_request
        response.should select_toolbox_frame(".document_#{@document.id}:resource(documents/show)")
      end

    end
    
    
    describe "get /edit" do

      def do_request
        get :edit, :id => @document.to_param, :format => 'js'
      end

      it_should_behave_like 'every request'
      it_should_behave_like 'every request with form'

      it "should render the contents form (document has no own yet )" do
        do_request
        response.should render_template('documents/_form.html.erb')
      end

      it "should replace the current frame ('show')" do
        @request.env['Tirade-Frame'] = '2342'
        do_request
        response.should select_toolbox_frame('#frame_2342')
      end

    end

    describe "put /update with valid attributes" do

      def do_request
        put :update, :id => @document.to_param, :document => Factory.attributes_for(:document), :format => 'js'
      end
      
      it_should_behave_like 'every request'
      it_should_behave_like 'every request with form'
      it_should_behave_like 'every request that sets flash messages'

      it "should request refresh for all 'show' frames for the document" do
        do_request
        response.body.should request_refresh_for(@document, 'show')
      end

      it "should update current frame with 'show'" do
        @request.env['Tirade-Frame'] = '2342'
        do_request
        response.should render_template('documents/_show.html.erb')
        response.should select_toolbox_frame('#frame_2342')
      end
    end

    describe "put /update with valid attributes for 'de' locale" do
      def do_request
        put :update, :locale => 'de', :id => @document.to_param, :document => { :title => 'Deutscher Titel' }, :format => 'js'
      end

      it "should set locale from params" do
        pending "the :locale param does not reach the controller.."
        do_request
        Document.locale.should == :de
      end

      it "should create 'de' locale" do
        pending "the :locale param does not reach the controller.."
        lambda { do_request }.should change(DocumentTranslation, :count).by(1)
      end
    end

    describe "put /update with invalid attributes" do

      def do_request
        put :update, :id => @document.to_param, :document => Factory.attributes_for(:document), :format => 'js'
      end
      
      it_should_behave_like 'every request'
      it_should_behave_like 'every request with form'
      it_should_behave_like 'every request that sets flash messages'

      before( :each ) do
        @document.stub!(:valid?).and_return(false)
        Document.stub!(:find_by_slug).with(@document.to_param).and_return(@document)
      end

      it "should rerender the form" do
        do_request
        response.should render_template('documents/_form.html.erb')
      end

      it "should show validation errors" do
        do_request
        response.should set_notification('Failed to update Document')
      end

    end

    describe "put /preview" do

      def do_request
        put :preview, :id => @document.to_param, :document => Factory.attributes_for(:document), :format => 'js'
      end
      
      it_should_behave_like 'every request'

      it "should not select any frame" do
        do_request
        unescape_rjs(response.body).should_not have_text(%r~Toolbox.frames~)
        unescape_rjs(response.body).should_not have_text(%r~Toolbox.last~)
      end

      it "should update Renderings for previewed Content on current Page" do
        @request.env['Tirade-Page'] = '42'
        page = Factory :page
        rendering = Factory :rendering
        page.stub!(:renderings).and_return( mock(:for_content => [rendering]) )
        Page.should_receive(:find_by_id).with(42).and_return( page )
        do_request
        unescape_rjs(response.body).should have_text(%r~rendering_#{rendering.id}.*replaceWith.*rendering_#{rendering.id}~)
      end
    end


    describe "get /scopes.json" do
      def do_request
        get :scopes, :format => 'json'
      end

      it "should succeed" do
        do_request
        response.should be_success
      end

      it "should return json" do
        do_request
        lambda { @parsed = JSON.parse response.body }.should_not raise_error
        @parsed.should be_a(Hash)
      end
    end

    describe "get /scopes.html" do
      integrate_views
      def do_request
        get :scopes, :format => 'html'
      end
      
      it "should succeed" do
        do_request
        response.should be_success
      end

      it "should render scope_blueprint partial" do
        do_request
        response.should render_template('model/_scope_blueprint')
      end

      it "should render scoping blueprint div" do
        do_request
        response.should have_tag('div.scoping.blueprint') do
          with_tag('select.scope_attribute')
          with_tag('select.scope_comparison')
          with_tag('input.scope_value[type=text]')
        end
      end

      it "should render a field to select ordering" do
        do_request
        response.should have_tag('div.order') do
          with_tag('select.order_attribute') do
            with_tag('option[value=?]', 'title')
          end
          with_tag('select.order_direction') do
            with_tag('option[value=?]', 'ascend')
          end
        end
      end
    end

  end

  describe "Requesting XML" do

    before( :each ) do
      @document = Factory.create :document
    end

    describe "unauthorized" do

      describe "get index.xml" do
        def do_request
          get :index, :format => 'xml'
        end

        it "should not be successful" do
          do_request
          response.should_not be_success
        end
      end

      describe "get show.xml" do
        def do_request
          get :show, :id => @document.to_param, :format => 'xml'
        end

        it "should not be successful" do
          do_request
          response.should_not be_success
        end

        it "should deny access" do
          do_request
          response.code.should == "401"
        end
      end
      
    end


    describe "authorized to read" do

      before( :each ) do
        login_with_group :read_documents
        login_standard
      end

      describe "successful request", :shared => true do
        
        it "should be successful" do
          do_request
          response.should be_success
        end

        it "should return proper HTTP code" do
          do_request
          response.code.should == "200"
        end

        it "should xml" do
          do_request
          response.body.should include('xml')
        end

      end


      describe "get index.xml" do
        def do_request
          get :index, :format => 'xml'
        end

        it_should_behave_like 'successful request'

        it "should return a XML-formatted list of Documents" do
          do_request
          response.should have_tag('documents') do
            with_tag('document') do
              with_tag('title')
              with_tag('body')
            end
          end
        end

      end

      describe "get show.xml" do
        def do_request
          get :show, :id => @document.to_param, :format => 'xml'
        end

        it_should_behave_like 'successful request'

        it "should return a XML-formmated Document" do
          do_request
          response.should have_tag('document') do
            with_tag('title', @document.title)
            with_tag('body', @document.body)
          end
        end
      end

    end

  end

end
