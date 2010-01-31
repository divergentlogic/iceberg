require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Iceberg::Routes::Boards do
  describe "getting /boards" do
    before(:each) do
      @root     = Factory.build(:board, :title => "Root")
      @root.save
      @general  = Factory.build(:board, :title => "General", :parent => @root)
      @general.save
      @carriers = Factory.build(:board, :title => "Carriers", :parent => @root)
      @carriers.save
      @att      = Factory.build(:board, :title => "AT&T", :parent => @carriers)
      @att.save
      @sprint   = Factory.build(:board, :title => "Sprint", :parent => @carriers)
      @sprint.save
      @verizon  = Factory.build(:board, :title => "Verizon", :parent => @carriers)
      @verizon.save
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
      @board = Factory.build(:board, :title => "Fun Stuff", :parent => @root, :allow_topics => true)
      @board.save
    
      get "/boards/root/fun-stuff"
      last_response.should have_selector(".board_controls > a:contains('New Topic')")
    end
  
    it "should not display link to create a new topic if the board does not allows topics" do
      @board = Factory.build(:board, :title => "Fun Stuff", :parent => @root, :allow_topics => false)
      @board.save
    
      get "/boards/root/fun-stuff"
      last_response.should_not have_selector(".board_controls > a:contains('New Topic')")
    end
  end

  describe "viewing the ATOM feed" do
    before(:each) do
      @root   = Factory.create(:board, :title => "Root", :allow_topics => false)
      @board  = Factory.create(:board, :title => "Board", :parent => @root)
      
      # TODO add author
      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 6, 0, 0))
      @topic1 = @board.post_topic(nil, :title => "Topic 1", :message => "First post for Topic 1")
      
      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 7, 0, 0))
      @topic2 = @board.post_topic(nil, :title => "Topic 2", :message => "First post for Topic 2")
      @post1  = @topic2.posts.first
      
      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 8, 0, 0))
      @post2  = @post1.reply(nil, :message => "Second post for Topic 2")
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
    
    it "should have an entry for the first topic" do
      get "/boards/root/board.atom"
      
      last_response.body.should have_xpath("//feed/entry[1]/title[contains(text(), 'Topic 1')]")
      last_response.body.should have_xpath("//feed/entry[1]/link[@href='http://example.org/boards/root/board/topics/topic-1'][@rel='alternate'][@type='text/html']")
      last_response.body.should have_xpath("//feed/entry[1]/id[contains(text(), 'http://example.org/boards/root/board/topics/topic-1')]")
      last_response.body.should have_xpath("//feed/entry[1]/updated[contains(text(), '2010-01-01T06:00:00Z')]")
      # TODO add author
      last_response.body.should have_xpath("//feed/entry[1]/author/name")
      last_response.body.should have_xpath("//feed/entry[1]/content[@type='html'][contains(text(), 'First post for Topic 1')]")
    end
    
    it "should have an entry for the second topic" do
      get "/boards/root/board.atom"
      
      last_response.body.should have_xpath("//feed/entry[2]/title[contains(text(), 'Topic 2')]")
      last_response.body.should have_xpath("//feed/entry[2]/link[@href='http://example.org/boards/root/board/topics/topic-2'][@rel='alternate'][@type='text/html']")
      last_response.body.should have_xpath("//feed/entry[2]/id[contains(text(), 'http://example.org/boards/root/board/topics/topic-2')]")
      last_response.body.should have_xpath("//feed/entry[2]/updated[contains(text(), '2010-01-01T08:00:00Z')]")
      # TODO add author
      last_response.body.should have_xpath("//feed/entry[2]/author/name")
      last_response.body.should have_xpath("//feed/entry[2]/content[@type='html'][contains(text(), 'Second post for Topic 2')]")
    end
  end
end
