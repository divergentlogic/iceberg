require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Board" do
  it "should save with valid attributes" do
    @board = TestApp::Board.generate
    @board.save.should be_true
  end

  [:title, :description].each do |field|
    it "should validate presence of #{field}" do
      @board = TestApp::Board.generate(field => nil)
      @board.valid?
      @board.should error_on(field)
    end
  end

  it "should set the slug based on title" do
    @board = TestApp::Board.generate(:title => "Here is a title")
    @board.save
    @board.slug.should == "here-is-a-title"

    @board = TestApp::Board.generate(:title => "I have $5")
    @board.save
    @board.slug.should == "i-have-5-dollars"
  end

  it "should not change the slug if the title is updated" do
    @board = TestApp::Board.generate(:title => "Here is a title")
    @board.save
    @board.slug.should == "here-is-a-title"

    @board.title = "New Title"
    @board.save
    @board.title.should == "New Title"
    @board.slug.should  == "here-is-a-title"
  end

  it "should have unique titles at the same level in the tree" do
    @board = TestApp::Board.generate(:title => "Hello world")
    @fail  = TestApp::Board.make(:title => "Hello world")
    @fail.valid?
    @fail.should error_on(:title)
    @success = TestApp::Board.make(:title => "Goodbye cruel world")
    @success.valid?
    @success.should_not error_on(:title)

    TestApp::Board.generate(:title => "Goodbye cruel world", :parent => @board)
    @fail = TestApp::Board.make(:title => "Goodbye cruel world", :parent => @board)
    @fail.valid?
    @fail.should error_on(:title)
    @success = TestApp::Board.make(:title => "Hello world", :parent => @board)
    @success.valid?
    @success.should_not error_on(:title)
  end

  it "should delete in a paranoid fashion" do
    Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 1, 0, 0))
    @board = TestApp::Board.generate(:title => "Hello world")
    @board.destroy
    @board.deleted_at.should == Time.utc(2010, 1, 1, 1, 0, 0)
  end

  it "should allow titles to be reused from deleted boards" do
    @board = TestApp::Board.generate(:title => "Hello world")
    @board.destroy

    @new = TestApp::Board.make(:title => "Hello world")
    @new.save.should be_true
  end

  describe "#post_topic" do
    before(:each) do
      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 1, 0, 0))
      @board  = TestApp::Board.generate
      @author = Iceberg::App::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @topic  = @board.post_topic(@author, {:title => "Hello there", :message => "Welcome to my topic"})
      @post   = @topic.posts.first

      @board.reload
      @topic.reload
    end

    it "should fail if a title is not provided" do
      topic = @board.post_topic(@author, :message => "This needs a title")
      topic.should be_new
      topic.should error_on(:title)
      topic.posts.should be_empty
    end

    it "should fail if a message is not provided" do
      topic = @board.post_topic(@author, :title => "This needs a message")
      topic.should be_new
      topic.should error_on(:message)
      topic.posts.should be_empty
    end

    it "should create a topic" do
      @topic.title.should == "Hello there"
    end

    it "should create a post" do
      @post.message.should == "Welcome to my topic"
    end

    it "should update the topic cache" do
      @topic.last_post.should                   == @post
      @topic.last_updated_at.to_s.should        == @post.updated_at.to_s
      @topic.last_author_id.should              == 1
      @topic.last_author_name.should            == "Billy Gnosis"
      @topic.last_author_ip_address.to_s.should == "127.0.0.1"
      @topic.posts_count.should                 == 1
    end

    it "should update the board cache" do
      @board.last_post.should                   == @post
      @board.last_topic.should                  == @topic
      @board.last_updated_at.to_s.should        == @post.updated_at.to_s
      @board.last_author_id.should              == 1
      @board.last_author_name.should            == "Billy Gnosis"
      @board.last_author_ip_address.to_s.should == "127.0.0.1"
      @board.topics_count.should                == 1
      @board.posts_count.should                 == 1
    end

    describe "creating another post" do
      before(:each) do
        Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 2, 0, 0))
        @new_author = Iceberg::App::Author.new(:id => 2, :name => "Mickey Mouse", :ip_address => "192.168.1.1")
        @new_post   = @post.reply(@new_author, :message => "Hello there")

        @topic.reload
        @board.reload
      end

      it "should update the topic cache" do
        @topic.last_post.should                   == @new_post
        @topic.last_updated_at.to_s.should        == @new_post.updated_at.to_s
        @topic.last_author_id.should              == 2
        @topic.last_author_name.should            == "Mickey Mouse"
        @topic.last_author_ip_address.to_s.should == "192.168.1.1"
        @topic.posts_count.should                 == 2
      end

      it "should update the board cache" do
        @board.last_post.should                   == @new_post
        @board.last_topic.should                  == @topic
        @board.last_updated_at.to_s.should        == @new_post.updated_at.to_s
        @board.last_author_id.should              == 2
        @board.last_author_name.should            == "Mickey Mouse"
        @board.last_author_ip_address.to_s.should == "192.168.1.1"
        @board.topics_count.should                == 1
        @board.posts_count.should                 == 2
      end
    end

    describe "creating another topic" do
      before(:each) do
        Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 2, 0, 0))
        @new_author = Iceberg::App::Author.new(:id => 2, :name => "Mickey Mouse", :ip_address => "192.168.1.1")
        @new_topic  = @board.post_topic(@new_author, :title => "New Topic", :message => "Hello there")
        @new_post   = @new_topic.posts.first

        @new_topic.reload
        @board.reload
      end

      it "should update the board cache" do
        @board.last_post.should                   == @new_post
        @board.last_topic.should                  == @new_topic
        @board.last_updated_at.to_s.should        == @new_post.updated_at.to_s
        @board.last_author_id.should              == 2
        @board.last_author_name.should            == "Mickey Mouse"
        @board.last_author_ip_address.to_s.should == "192.168.1.1"
        @board.topics_count.should                == 2
        @board.posts_count.should                 == 2
      end
    end

    it "should fail if the board does not allow topics" do
      board = TestApp::Board.generate(:allow_topics => false)
      topic = board.post_topic(@author, {:title => "Don't allow topics", :message => "This will fail"})
      topic.should error_on(:board)
    end
  end

  describe "tree" do
    before(:each) do
      @general_board  = TestApp::Board.generate(:title => "General")
      @carriers_board = TestApp::Board.generate(:title => "Carriers", :parent => @general_board)
      @verizon_board  = TestApp::Board.generate(:title => "Verizon", :parent => @carriers_board)
    end

    it "should have children" do
      @board = TestApp::Board.first(:parent_id => nil)
      @board.should == @general_board

      @board = @board.children.first
      @board.should == @carriers_board

      @board = @board.children.first
      @board.should == @verizon_board
    end

    describe "#by_ancestory" do
      it "should retrieve the child given correct slugs" do
        @board = TestApp::Board.by_ancestory(%w[general carriers verizon])
        @board.should == @verizon_board
      end

      it "should not retrieve the child given incorrect slugs" do
        @board = TestApp::Board.by_ancestory(%w[carriers general verizon])
        @board.should be_nil
      end
    end

    describe "#ancestory" do
      it "should return and array of slugs from self moving up tree" do
        @verizon_board.ancestory.should == %w[general carriers verizon]
        @carriers_board.ancestory.should == %w[general carriers]
        @general_board.ancestory.should == %w[general]
      end
    end

    describe "#ancestory_path" do
      it "should return a URL path of the ancestory" do
        @verizon_board.ancestory_path.should == "general/carriers/verizon"
        @carriers_board.ancestory_path.should == "general/carriers"
        @general_board.ancestory_path.should == "general"
      end
    end
  end
end
