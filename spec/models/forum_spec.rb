require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Iceberg::Forum do
  it "should save with valid attributes" do
    @forum = Factory.build(:forum)
    @forum.save.should be_true
  end
  
  [:title, :description].each do |field|
    it "should validate presence of #{field}" do
      @forum = Factory.build(:forum, field => nil)
      @forum.should error_on(field)
    end
  end
  
  it "should set the slug based on title" do
    @forum = Factory.build(:forum, :title => "Here is a title")
    @forum.save
    @forum.slug.should == "here-is-a-title"
    
    @forum = Factory.build(:forum, :title => "I have $5")
    @forum.save
    @forum.slug.should == "i-have-5-dollars"
  end
  
  it "should have unique titles at the same level in the tree" do
    @forum = Factory.create(:forum, :title => "Hello world")
    @fail = Factory.build(:forum, :title => "Hello world")
    @fail.should error_on(:title)
    @success = Factory.build(:forum, :title => "Goodbye cruel world")
    @success.should_not error_on(:title)
    
    Factory.create(:forum, :title => "Goodbye cruel world", :parent => @forum)
    @fail = Factory.build(:forum, :title => "Goodbye cruel world", :parent => @forum)
    @fail.should error_on(:title)
    @success = Factory.build(:forum, :title => "Hello world", :parent => @forum)
    @success.should_not error_on(:title)
  end
  
  describe "#post_topic" do
    it "should create a topic with a post and update topic and forum" do
      @forum = Factory.build(:forum)
      @forum.save
      # TODO add author
      @topic = @forum.post_topic(nil, {:title => "Hello there", :message => "Welcome to my topic"})
      @forum.reload
      
      @post = @topic.posts.first
      @post.message.should == "Welcome to my topic"

      @topic.last_post.should == @post
      @topic.last_updated_at.should == @post.updated_at
      @topic.posts_count.should == 1
      
      @forum.last_post.should == @post
      @forum.last_updated_at.should == @post.updated_at
      @forum.topics_count.should == 1
      @forum.posts_count.should == 1
    end
    
    it "should fail if the forum does not allow topics" do
      @forum = Factory.build(:forum, :allow_topics => false)
      @forum.save

      @topic = @forum.post_topic(nil, {:title => "Hello there", :message => "Welcome to my topic"})
      @topic.should error_on(:forum)
    end
  end
  
  describe "tree" do
    before(:each) do
      @general_forum = Factory.build(:forum, :title => "General")
      @general_forum.save
      @carriers_forum = Factory.build(:forum, :title => "Carriers", :parent => @general_forum)
      @carriers_forum.save
      @verizon_forum = Factory.build(:forum, :title => "Verizon", :parent => @carriers_forum)
      @verizon_forum.save
    end
    
    it "should have children" do
      @forum = Iceberg::Forum.first(:parent_id => nil)
      @forum.should == @general_forum
      
      @forum = @forum.children.first
      @forum.should == @carriers_forum
      
      @forum = @forum.children.first
      @forum.should == @verizon_forum
    end
    
    describe "#by_ancestory" do
      it "should retrieve the child given correct slugs" do
        @forum = Iceberg::Forum.by_ancestory(%w[general carriers verizon])
        @forum.should == @verizon_forum
      end
      
      it "should not retrieve the child given incorrect slugs" do
        @forum = Iceberg::Forum.by_ancestory(%w[carriers general verizon])
        @forum.should be_nil
      end
    end
    
    describe "#ancestory" do
      it "should return and array of slugs from self moving up tree" do
        @verizon_forum.ancestory.should == %w[general carriers verizon]
        @carriers_forum.ancestory.should == %w[general carriers]
        @general_forum.ancestory.should == %w[general]
      end
    end
    
    describe "#ancestory_path" do
      it "should return a URL path of the ancestory" do
        @verizon_forum.ancestory_path.should == "general/carriers/verizon"
        @carriers_forum.ancestory_path.should == "general/carriers"
        @general_forum.ancestory_path.should == "general"
      end
    end
  end
end
