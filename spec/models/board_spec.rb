require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Iceberg::Board do
  it "should save with valid attributes" do
    @board = Factory.build(:board)
    @board.save.should be_true
  end
  
  [:title, :description].each do |field|
    it "should validate presence of #{field}" do
      @board = Factory.build(:board, field => nil)
      @board.should error_on(field)
    end
  end
  
  it "should set the slug based on title" do
    @board = Factory.build(:board, :title => "Here is a title")
    @board.save
    @board.slug.should == "here-is-a-title"
    
    @board = Factory.build(:board, :title => "I have $5")
    @board.save
    @board.slug.should == "i-have-5-dollars"
  end
  
  it "should have unique titles at the same level in the tree" do
    @board = Factory.create(:board, :title => "Hello world")
    @fail = Factory.build(:board, :title => "Hello world")
    @fail.should error_on(:title)
    @success = Factory.build(:board, :title => "Goodbye cruel world")
    @success.should_not error_on(:title)
    
    Factory.create(:board, :title => "Goodbye cruel world", :parent => @board)
    @fail = Factory.build(:board, :title => "Goodbye cruel world", :parent => @board)
    @fail.should error_on(:title)
    @success = Factory.build(:board, :title => "Hello world", :parent => @board)
    @success.should_not error_on(:title)
  end
  
  describe "#post_topic" do
    before(:each) do
      @board  = Factory.create(:board)
      @author = Iceberg::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @topic  = @board.post_topic(@author, {:title => "Hello there", :message => "Welcome to my topic"})
    end
    
    it "should create a topic" do
      @topic.title.should == "Hello there"
    end
    
    it "should create a post" do
      @post = @topic.posts.first
      @post.message.should == "Welcome to my topic"
    end
    
    it "should update the topic cache" do
      @post = @topic.posts.first
      @topic.last_post.should                   == @post
      @topic.last_updated_at.to_s.should        == @post.updated_at.to_s
      @topic.last_author_id.should              == 1
      @topic.last_author_name.should            == "Billy Gnosis"
      @topic.last_author_ip_address.to_s.should == "127.0.0.1"
      @topic.posts_count.should                 == 1
    end
    
    it "should update the board cache" do
      @post = @topic.posts.first
      @board.last_post.should                   == @post
      @board.last_topic.should                  == @topic
      @board.last_updated_at.to_s.should        == @post.updated_at.to_s
      @board.last_author_id.should              == 1
      @board.last_author_name.should            == "Billy Gnosis"
      @board.last_author_ip_address.to_s.should == "127.0.0.1"
      @board.topics_count.should                == 1
      @board.posts_count.should                 == 1
    end
    
    it "should fail if the board does not allow topics" do
      board = Factory.create(:board, :allow_topics => false)
      topic = board.post_topic(@author, {:title => "Hello there", :message => "Welcome to my topic"})
      topic.should error_on(:board)
    end
  end
  
  describe "tree" do
    before(:each) do
      @general_board = Factory.build(:board, :title => "General")
      @general_board.save
      @carriers_board = Factory.build(:board, :title => "Carriers", :parent => @general_board)
      @carriers_board.save
      @verizon_board = Factory.build(:board, :title => "Verizon", :parent => @carriers_board)
      @verizon_board.save
    end
    
    it "should have children" do
      @board = Iceberg::Board.first(:parent_id => nil)
      @board.should == @general_board
      
      @board = @board.children.first
      @board.should == @carriers_board
      
      @board = @board.children.first
      @board.should == @verizon_board
    end
    
    describe "#by_ancestory" do
      it "should retrieve the child given correct slugs" do
        @board = Iceberg::Board.by_ancestory(%w[general carriers verizon])
        @board.should == @verizon_board
      end
      
      it "should not retrieve the child given incorrect slugs" do
        @board = Iceberg::Board.by_ancestory(%w[carriers general verizon])
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
