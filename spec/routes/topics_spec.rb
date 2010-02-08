require File.dirname(__FILE__) + '/../spec_helper'

describe Iceberg::Routes::Topics do
  describe "moving a topic" do
    before(:each) do
      @original_board = Factory.create(:board, :title => "Original Board")
      @author         = Iceberg::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @topic          = @original_board.post_topic(@author, {:title => "My Topic", :message => "Move me"})
      @valid_board1   = Factory.create(:board, :title => "Valid Board 1")
      @valid_board2   = Factory.create(:board, :title => "Valid Board 2")
      @invalid_board  = Factory.create(:board, :title => "Invalid Board", :allow_topics => false)
    end
    
    describe "GET" do
      it "should be successful" do
        get "/topics/#{@topic.id}/move"
        last_response.should be_ok
      end
      
      it "should not match on non numeric parameters" do
        get "/topics/something-non-numeric/move"
        last_response.should be_not_found
      end
      
      it "should not match on IDs that begin with 0" do
        get "/topics/01/move"
        last_response.should be_not_found
      end
      
      it "should return 404 if the topic is not found" do
        get "/topics/99999999/move"
        last_response.should be_not_found
      end
      
      it "should display the title of the current board" do
        get "/topics/#{@topic.id}/move"
        last_response.body.should contain("Original Board")
      end
      
      it "should display the title of the topic" do
        get "/topics/#{@topic.id}/move"
        last_response.body.should contain("My Topic")
      end
      
      it "should have a form posting to the same action" do
        get "/topics/#{@topic.id}/move"
        last_response.body.should have_selector("form[action='/topics/#{@topic.id}/move'][method='post']")
      end
      
      it "should display a drop down of boards I can move the topic to" do
        get "/topics/#{@topic.id}/move"
        last_response.body.should have_selector("select > option[value='#{@valid_board1.id}']:contains('#{@valid_board1.title}')")
        last_response.body.should have_selector("select > option[value='#{@valid_board2.id}']:contains('#{@valid_board2.title}')")
      end
      
      it "should not display the topic's current board in the drop down" do
        get "/topics/#{@topic.id}/move"
        last_response.body.should_not have_selector("select > option[value='#{@original_board.id}']:contains('#{@original_board.title}')")
      end
      
      it "should not display boards that don't allow topics" do
        get "/topics/#{@topic.id}/move"
        last_response.body.should_not have_selector("select > option[value='#{@invalid_board.id}']:contains('#{@invalid_board.title}')")
      end
    end

    describe "POST" do
      it "should be successful" do
        post "/topics/#{@topic.id}/move", {'iceberg-topic' => {'board_id' => @valid_board1.id}}
        follow_redirect!
        last_response.should be_ok
      end
      
      it "should not match on non numeric parameters" do
        post "/topics/something-non-numeric/move"
        last_response.should be_not_found
      end
      
      it "should not match on IDs that begin with 0" do
        post "/topics/01/move"
        last_response.should be_not_found
      end
      
      it "should return 404 if the topic is not found" do
        post "/topics/99999999/move"
        last_response.should be_not_found
      end
      
      it "should not be successful if the board does not allow topics" do
        post "/topics/#{@topic.id}/move", {'iceberg-topic' => {'board_id' => @invalid_board.id}}
        last_response.body.should contain("This board does not allow topics")
      end
      
      it "should redirect to the topic page if successful" do
        post "/topics/#{@topic.id}/move", {'iceberg-topic' => {'board_id' => @valid_board1.id}}
        follow_redirect!
        last_request.path.should == "/boards/valid-board-1/topics/my-topic"
        last_response.body.should contain(@valid_board1.title)
      end
    end
  end
  
  describe "viewing the ATOM feed" do
    before(:each) do
      @board    = Factory.create(:board, :title => "Board")
      @author1  = Iceberg::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @author2  = Iceberg::Author.new(:id => 2, :name => "Brett Gurewitz", :ip_address => "192.168.1.1")
      @author3  = Iceberg::Author.new(:id => 3, :name => "Greg Graffin", :ip_address => "55.55.55.55")

      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 6, 0, 0))
      @topic = @board.post_topic(@author1, {:title => "Topic", :message => "First post"})
      @post1 = @topic.posts.first
      
      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 7, 0, 0))
      @post2 = @post1.reply(@author2, {:message => "Second post"})
      @post2.save
      
      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 8, 0, 0))
      @post3 = @post2.reply(@author3, {:message => "Third post"})
      @post3.save
    end
    
    it "should be successful" do
      get "/boards/board/topics/topic.atom"
      last_response.should be_ok
    end
    
    it "should return 404 if the board doesn't exist" do
      get "/boards/does-not-exist/topics/topic.atom"
      last_response.should be_not_found
    end
    
    it "should return 404 if the topic doesn't exist" do
      get "/boards/board/topics/does-not-exist.atom"
      last_response.should be_not_found
    end
    
    it "should have the ATOM Content Type set" do
      get "/boards/board/topics/topic.atom"
      last_response.headers['Content-Type'].should == 'application/atom+xml'
    end
    
    it "should be a valid ATOM feed" do
      get "/boards/board/topics/topic.atom"
      last_response.body.should be_valid_atom
    end
    
    it "should have an entry for the first post" do
      get "/boards/board/topics/topic.atom"
      
      last_response.body.should have_xpath("//feed/entry[1]/title[contains(text(), 'Topic')]")
      last_response.body.should have_xpath("//feed/entry[1]/link[@href='http://example.org/boards/board/topics/topic#1'][@rel='alternate'][@type='text/html']")
      last_response.body.should have_xpath("//feed/entry[1]/id[contains(text(), 'http://example.org/boards/board/topics/topic#1')]")
      last_response.body.should have_xpath("//feed/entry[1]/updated[contains(text(), '2010-01-01T06:00:00Z')]")
      last_response.body.should have_xpath("//feed/entry[1]/author/name[contains(text(), 'Billy Gnosis')]")
      last_response.body.should have_xpath("//feed/entry[1]/content[@type='html'][contains(text(), 'First post')]")
    end
    
    it "should have an entry for the second post" do
      get "/boards/board/topics/topic.atom"
      
      last_response.body.should have_xpath("//feed/entry[2]/title[contains(text(), 'Topic')]")
      last_response.body.should have_xpath("//feed/entry[2]/link[@href='http://example.org/boards/board/topics/topic#2'][@rel='alternate'][@type='text/html']")
      last_response.body.should have_xpath("//feed/entry[2]/id[contains(text(), 'http://example.org/boards/board/topics/topic#2')]")
      last_response.body.should have_xpath("//feed/entry[2]/updated[contains(text(), '2010-01-01T07:00:00Z')]")
      last_response.body.should have_xpath("//feed/entry[2]/author/name[contains(text(), 'Brett Gurewitz')]")
      last_response.body.should have_xpath("//feed/entry[2]/content[@type='html'][contains(text(), 'Second post')]")
    end
    
    it "should have an entry for the third post" do
      get "/boards/board/topics/topic.atom"
      
      last_response.body.should have_xpath("//feed/entry[3]/title[contains(text(), 'Topic')]")
      last_response.body.should have_xpath("//feed/entry[3]/link[@href='http://example.org/boards/board/topics/topic#3'][@rel='alternate'][@type='text/html']")
      last_response.body.should have_xpath("//feed/entry[3]/id[contains(text(), 'http://example.org/boards/board/topics/topic#3')]")
      last_response.body.should have_xpath("//feed/entry[3]/updated[contains(text(), '2010-01-01T08:00:00Z')]")
      last_response.body.should have_xpath("//feed/entry[3]/author/name[contains(text(), 'Greg Graffin')]")
      last_response.body.should have_xpath("//feed/entry[3]/content[@type='html'][contains(text(), 'Third post')]")
    end
  end
end
