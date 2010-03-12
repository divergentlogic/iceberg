require File.dirname(__FILE__) + '/../spec_helper'

describe "Posts Routes" do
  describe "replying to a post" do
    before(:each) do
      @board  = Factory.create(:board, :title => "Board")
      @author = Iceberg::App::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @topic  = @board.post_topic(@author, {:title => "Topic", :message => "Discuss"})
      @post   = @topic.posts.first
    end
    
    it "should be successful with a topic without quoting" do
      get "/topics/#{@topic.id}/posts/reply"
      last_response.should be_ok
      last_response.body.should_not have_selector("textarea:contains('Discuss')")
    end
    
    it "should be successful with a topic with quoting" do
      get "/topics/#{@topic.id}/posts/reply?quote=true"
      last_response.should be_ok
      last_response.body.should have_selector("textarea:contains('Discuss')")
    end
    
    it "should be successful with a post without quoting" do
      get "/topics/#{@topic.id}/posts/#{@post.id}/reply"
      last_response.should be_ok
      last_response.body.should_not have_selector("textarea:contains('Discuss')")
    end
    
    it "should be successful with a post with quoting" do
      get "/topics/#{@topic.id}/posts/#{@post.id}/reply?quote=true"
      last_response.should be_ok
      last_response.body.should have_selector("textarea:contains('Discuss')")
    end
  end
  
  describe "creating a new post" do
    before(:each) do
      @board  = Factory.create(:board, :title => "Board")
      @author = Iceberg::App::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @topic  = @board.post_topic(@author, {:title => "Topic", :message => "Discuss"})
      @post   = @topic.posts.first
      
      post "/posts/#{@post.id}", {'test_app-post' => {'message' => 'Yo Dawg'}}
      follow_redirect!
    end
    
    it "should be successful" do
      last_response.should be_ok
    end
    
    it "should redirect to the topic page" do
      last_request.path.should == "/boards/board/topics/topic"
    end
    
    it "should post default author attributes" do
      last_response.body.should contain('Anonymous')
    end
  end
  
  describe "deleting a post" do
    before(:each) do
      @board  = Factory.create(:board, :title => "Talk about stuff")
      @author = Iceberg::App::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @topic  = @board.post_topic(@author, {:title => "Yak Yak Yak", :message => "Hello World"})
      @post   = @topic.posts.first
    end
    
    it "should be successful" do
      delete "/posts/#{@post.id}"
      follow_redirect!
      last_response.should be_ok
    end

    it "should not match on non numeric parameters" do
      delete "/posts/something-non-numeric"
      last_response.should be_not_found
    end
    
    it "should not match on IDs that begin with 0" do
      delete "/posts/01"
      last_response.should be_not_found
    end
    
    it "should return 404 if the topic is not found" do
      delete "/posts/99999999"
      last_response.should be_not_found
    end
    
    it "should delete the post" do
      get "/boards/talk-about-stuff/topics/yak-yak-yak"
      last_response.should contain("Hello World")
      
      delete "/posts/#{@post.id}"
      
      get "/boards/talk-about-stuff/topics/yak-yak-yak"
      last_response.should_not contain("Hello World")
    end
  end
end
