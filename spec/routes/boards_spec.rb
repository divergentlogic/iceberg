require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Boards Routes" do
  describe "new board" do
    before(:each) do
      @root = Factory.build(:board, :title => "Root")
      @root.save
    end

    describe "GET" do
      it "should be successful" do
        get "/boards/new"
        last_response.should be_ok
      end

      it "should be successful with a parent" do
        get "/boards/#{@root.id}/new"
        last_response.should be_ok
      end

      it "should not match on non numeric parameters" do
        get "/boards/something-non-numeric/new"
        last_response.should be_not_found
      end

      it "should not match on IDs that begin with 0" do
        get "/boards/01/new"
        last_response.should be_not_found
      end

      it "should return not found if the parent doesn't exist" do
        get "/boards/99999/new"
        last_response.should be_not_found
      end

      it "should have a form posting to the boards path" do
        get "/boards/#{@root.id}/new"
        last_response.body.should have_xpath("//form[@action='/boards'][@method='post']")
      end

      it "should have a hidden field for the parent ID if parent exists" do
        get "/boards/#{@root.id}/new"
        last_response.body.should have_xpath("//form/input[@name='test_app-board[parent_id]'][@type='hidden'][@value='#{@root.id}']")
      end

      it "should NOT have a hidden field for the parent if there is no parent" do
        get "/boards/new"
        last_response.body.should_not have_xpath("//form/input[@name='test_app-board[parent_id]'][@type='hidden']")
      end

      it "should have a text field for the title" do
        get "/boards/#{@root.id}/new"
        last_response.body.should have_xpath("//form/input[@name='test_app-board[title]'][@type='text']")
      end

      it "should have a text area for the descriptions" do
        get "/boards/#{@root.id}/new"
        last_response.body.should have_xpath("//form/textarea[@name='test_app-board[description]']")
      end

      it "should have a checkbox for allowing topics" do
        get "/boards/#{@root.id}/new"
        last_response.body.should have_xpath("//form/input[@name='test_app-board[allow_topics]'][@type='checkbox'][@value='1'][@checked='checked']")
        last_response.body.should have_xpath("//form/input[@name='test_app-board[allow_topics]'][@type='hidden'][@value='0']")
      end
    end

    describe "POST" do
      it "should be successful" do
        post "/boards", {'test_app-board' => {'title' => 'New Board', 'description' => 'My new board', 'allow_topics' => 0}}
        follow_redirect!
        last_response.should be_ok
      end

      it "should be successful with a parent" do
        post "/boards", {'test_app-board' => {'parent_id' => @root.id, 'title' => 'New Board', 'description' => 'My new board', 'allow_topics' => 1}}
        follow_redirect!
        last_response.should be_ok
      end

      it "should redirect to the board index page on success" do
        post "/boards", {'test_app-board' => {'title' => 'New Board', 'description' => 'My new board', 'allow_topics' => 0}}
        follow_redirect!
        last_request.path.should == "/boards"
      end

      it "should redirect to the board's parent page if parent is provided" do
        post "/boards", {'test_app-board' => {'parent_id' => @root.id, 'title' => 'New Board', 'description' => 'My new board', 'allow_topics' => 1}}
        follow_redirect!
        last_request.path.should == "/boards/root"
      end

      it "should render the new board page if creation fails" do
        post "/boards", {'test_app-board' => {'title' => 'Root', 'description' => 'Going to fail', 'allow_topics' => 0}}
        last_request.path.should  == "/boards"
        last_response.body.should contain("There's already a board with that title")
      end
    end
  end

  describe "edit board" do
    before(:each) do
      @board = Factory.build(:board, :title => "Board", :description => "First board", :allow_topics => true)
      @board.save
    end

    describe "GET" do
      it "should be successful" do
        get "/boards/#{@board.id}/edit"
        last_response.should be_ok
      end

      it "should not match on non numeric parameters" do
        get "/boards/something-non-numeric/edit"
        last_response.should be_not_found
      end

      it "should not match on IDs that begin with 0" do
        get "/boards/01/edit"
        last_response.should be_not_found
      end

      it "should return 404 if the board is not found" do
        get "/boards/99999999/edit"
        last_response.should be_not_found
      end

      it "should have a form posting to the update board path" do
        get "/boards/#{@board.id}/edit"
        last_response.body.should have_xpath("//form[@action='/boards/#{@board.id}'][@method='post']")
      end

      it "should have a hidden field for the PUT method" do
        get "/boards/#{@board.id}/edit"
        last_response.body.should have_xpath("//form/input[@name='_method'][@type='hidden'][@value='put']")
      end

      it "should have a text field for the title" do
        get "/boards/#{@board.id}/edit"
        last_response.body.should have_xpath("//form/input[@name='test_app-board[title]'][@type='text'][@value='Board']")
      end

      it "should have a text area for description" do
        get "/boards/#{@board.id}/edit"
        last_response.body.should have_xpath("//form/textarea[@name='test_app-board[description]'][contains(text(), 'First board')]")
      end

      it "should have a checkbox for allowing topics" do
        get "/boards/#{@board.id}/edit"
        last_response.body.should have_xpath("//form/input[@name='test_app-board[allow_topics]'][@type='checkbox'][@value='1']")
        last_response.body.should have_xpath("//form/input[@name='test_app-board[allow_topics]'][@type='hidden'][@value='0']")
      end
    end

    describe "PUT" do
      it "should be successful" do
        put "/boards/#{@board.id}", {'test_app-board' => {'title' => 'New Board', 'description' => 'My new board', 'allow_topics' => 0}}
        follow_redirect!
        last_response.should be_ok
      end

      it "should not match on non numeric parameters" do
        put "/boards/something-non-numeric"
        last_response.should be_not_found
      end

      it "should not match on IDs that begin with 0" do
        put "/boards/01"
        last_response.should be_not_found
      end

      it "should return 404 if the board is not found" do
        put "/boards/99999999"
        last_response.should be_not_found
      end

      it "should redirect to the board page if successful" do
        put "/boards/#{@board.id}", {'test_app-board' => {'title' => 'New Board', 'description' => 'My new board', 'allow_topics' => 0}}
        follow_redirect!
        last_request.path.should  == "/boards/board"
        last_response.body.should contain('New Board')
      end

      it "should render the edit form with errors if the update is unsuccessful" do
        @new_board = Factory.create(:board, :title => 'New Board', :description => 'There will be a conflict with title')
        put "/boards/#{@board.id}", {'test_app-board' => {'title' => 'New Board', 'description' => 'My new board', 'allow_topics' => 0}}
        last_request.path.should  == "/boards/#{@board.id}"
        last_response.body.should have_xpath("//form[@action='/boards/#{@board.id}'][@method='post']")
        last_response.body.should contain("There's already a board with that title")
      end
    end
  end

  describe "boards" do
    describe "GET" do
      before(:each) do
        @root = Factory.create(:board, :title => "Root")
      end

      it "should retrieve the index page" do
        get "/boards"
        last_response.should be_ok
      end

      it "should return 404 for slugs that don't match to a board" do
        get "/boards/not-a-slug"
        last_response.should be_not_found
      end

      it "should display link to create a new topic if the board allows topics" do
        board = Factory.build(:board, :title => "Fun Stuff", :parent => @root, :allow_topics => true)
        board.save

        get "/boards/root/fun-stuff"
        last_response.should have_xpath("//a[contains(text(), 'New Topic')]")
      end

      it "should not display link to create a new topic if the board does not allows topics" do
        board = Factory.create(:board, :title => "Fun Stuff", :parent => @root, :allow_topics => false)
        board.save

        get "/boards/root/fun-stuff"
        last_response.should_not have_xpath("//a[contains(text(), 'New Topic')]")
      end

      it "should display topics stickiest first" do
        @root.post_topic(nil, :title => "Topic 1", :message => "First")
        @root.post_topic(nil, :title => "Topic 2", :message => "Second", :sticky => 2)
        @root.post_topic(nil, :title => "Topic 3", :message => "Third", :sticky => 1)

        get "/boards/root"
        last_response.body.should have_xpath("//table/tbody/tr[1]/td/a[contains(text(), 'Topic 2')]")
        last_response.body.should have_xpath("//table/tbody/tr[2]/td/a[contains(text(), 'Topic 3')]")
        last_response.body.should have_xpath("//table/tbody/tr[3]/td/a[contains(text(), 'Topic 1')]")
      end
    end

    describe "DELETE" do
      before(:each) do
        @board = Factory.build(:board, :title => "Talk about stuff")
        @board.save
      end

      it "should be successful" do
        delete "/boards/#{@board.id}"
        follow_redirect!
        last_response.should be_ok
      end

      it "should not match on non numeric parameters" do
        delete "/boards/something-non-numeric"
        last_response.should be_not_found
      end

      it "should not match on IDs that begin with 0" do
        delete "/boards/01"
        last_response.should be_not_found
      end

      it "should return 404 if the board is not found" do
        delete "/boards/99999999"
        last_response.should be_not_found
      end

      it "should delete the board" do
        get "/boards"
        last_response.should contain("Talk about stuff")

        get "/boards/talk-about-stuff"
        last_response.should be_ok

        delete "/boards/#{@board.id}"

        get "/boards"
        last_response.should_not contain("Talk about stuff")

        get "/boards/talk-about-stuff"
        last_response.should be_not_found
      end
    end
  end

  describe "viewing the ATOM feed" do
    before(:each) do
      @root     = Factory.create(:board, :title => "Root", :allow_topics => false)
      @board    = Factory.create(:board, :title => "Board", :parent => @root)
      @author1  = Iceberg::App::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @author2  = Iceberg::App::Author.new(:id => 2, :name => "Brett Gurewitz", :ip_address => "127.0.0.1")

      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 6, 0, 0))
      @topic1 = @board.post_topic(@author1, :title => "Topic 1", :message => "First post for Topic 1", :sticky => 1)

      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 7, 0, 0))
      @topic2 = @board.post_topic(@author1, :title => "Topic 2", :message => "First post for Topic 2")
      @post1  = @topic2.posts.first

      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 8, 0, 0))
      @post2  = @post1.reply(@author2, :message => "Second post for Topic 2")
      @post2.save
    end

    it "should be successful" do
      get "/boards/root/board.atom"
      last_response.should be_ok
    end

    it "should return 404 if the board doesn't exist" do
      get "/boards/does-not-exist.atom"
      last_response.should be_not_found
    end

    it "should return 404 for boards that don't allow topics" do
      get "/boards/root.atom"
      last_response.should be_not_found
    end

    it "should have the ATOM Content Type set" do
      get "/boards/root/board.atom"
      last_response.headers['Content-Type'].should == 'application/atom+xml'
    end

    it "should be a valid ATOM feed" do
      get "/boards/root/board.atom"
      last_response.body.should be_valid_atom
    end

    it "should display the newest topic first, regardless of stickiness" do
      get "/boards/root/board.atom"

      last_response.body.should have_xpath("//feed/entry[1]/title[contains(text(), 'Topic 2')]")
      last_response.body.should have_xpath("//feed/entry[1]/link[@href='http://example.org/boards/root/board/topics/topic-2'][@rel='alternate'][@type='text/html']")
      last_response.body.should have_xpath("//feed/entry[1]/id[contains(text(), 'http://example.org/boards/root/board/topics/topic-2')]")
      last_response.body.should have_xpath("//feed/entry[1]/updated[contains(text(), '2010-01-01T08:00:00Z')]")
      last_response.body.should have_xpath("//feed/entry[1]/author/name[contains(text(), 'Brett Gurewitz')]")
      last_response.body.should have_xpath("//feed/entry[1]/content[@type='html'][contains(text(), 'Second post for Topic 2')]")
    end

    it "should display the oldest topic last, regardless of stickiness" do
      get "/boards/root/board.atom"

      last_response.body.should have_xpath("//feed/entry[2]/title[contains(text(), 'Topic 1')]")
      last_response.body.should have_xpath("//feed/entry[2]/link[@href='http://example.org/boards/root/board/topics/topic-1'][@rel='alternate'][@type='text/html']")
      last_response.body.should have_xpath("//feed/entry[2]/id[contains(text(), 'http://example.org/boards/root/board/topics/topic-1')]")
      last_response.body.should have_xpath("//feed/entry[2]/updated[contains(text(), '2010-01-01T06:00:00Z')]")
      last_response.body.should have_xpath("//feed/entry[2]/author/name[contains(text(), 'Billy Gnosis')]")
      last_response.body.should have_xpath("//feed/entry[2]/content[@type='html'][contains(text(), 'First post for Topic 1')]")
    end
  end
end
