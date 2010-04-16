require File.dirname(__FILE__) + '/../spec_helper'

describe "Posts Routes" do
  describe "replying to a post" do
    before(:each) do
      @board  = TestApp::Board.generate(:title => "Board")
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
      @board  = TestApp::Board.generate(:title => "Board")
      @author = Iceberg::App::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @topic  = @board.post_topic(@author, {:title => "Topic", :message => "Discuss"})
      @post   = @topic.posts.first
    end

    describe "without errors" do
      before(:each) do
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

    describe "with errors" do
      it "should render the post reply form" do
        post "/posts/#{@post.id}", {'test_app-post' => {'message' => ''}}
        last_request.path.should == "/posts/#{@post.id}"
        last_response.body.should contain('Message must not be blank')
        last_response.body.should have_selector("textarea")
      end
    end
  end

  describe "deleting a post" do
    before(:each) do
      @board  = TestApp::Board.generate(:title => "Talk about stuff")
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

    it "should return 404 if the post is not found" do
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

  describe "editing a post" do
    before(:each) do
      @board  = TestApp::Board.generate(:title => "Talk about stuff")
      @author = Iceberg::App::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @topic  = @board.post_topic(@author, {:title => "Yak Yak Yak", :message => "Hello World"})
      @post   = @topic.posts.first
    end

    it "should be successful" do
      get "/posts/#{@post.id}/edit"
      last_response.should be_ok
    end

    it "should not match on non numeric parameters" do
      put "/posts/something-non-numeric/edit"
      last_response.should be_not_found
    end

    it "should not match on IDs that begin with 0" do
      put "/posts/01/edit"
      last_response.should be_not_found
    end

    it "should return 404 if the post is not found" do
      put "/posts/99999999/edit"
      last_response.should be_not_found
    end

    it "should contain an edit form" do
      get "/posts/#{@post.id}/edit"
      last_response.body.should have_xpath("//textarea[contains(text(), 'Hello World')]")
    end
  end

  describe "updating a post" do
    before(:each) do
      @board  = TestApp::Board.generate(:title => "Talk about stuff")
      @author = Iceberg::App::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @topic  = @board.post_topic(@author, {:title => "Yak Yak Yak", :message => "Hello World"})
      @post   = @topic.posts.first
    end

    it "should be successful" do
      put "/posts/#{@post.id}", {'test_app-post' => {'message' => 'Yo Dawg'}}
      follow_redirect!
      last_response.should be_ok
    end

    it "should not match on non numeric parameters" do
      put "/posts/something-non-numeric"
      last_response.should be_not_found
    end

    it "should not match on IDs that begin with 0" do
      put "/posts/01"
      last_response.should be_not_found
    end

    it "should return 404 if the post is not found" do
      put "/posts/99999999"
      last_response.should be_not_found
    end

    it "should redirect to the post's topic" do
      put "/posts/#{@post.id}", {'test_app-post' => {'message' => 'Yo Dawg'}}
      follow_redirect!
      last_request.path.should == "/boards/talk-about-stuff/topics/yak-yak-yak"
    end

    it "should render the edit form if there are errors" do
      put "/posts/#{@post.id}", {'test_app-post' => {'message' => ''}}
      last_request.path.should == "/posts/#{@post.id}"
      last_response.body.should contain('Message must not be blank')
      last_response.body.should have_selector("textarea")
    end

    it "should update the post" do
      get "/boards/talk-about-stuff/topics/yak-yak-yak"
      last_response.should contain("Hello World")

      put "/posts/#{@post.id}", {'test_app-post' => {'message' => 'Yo Dawg'}}

      get "/boards/talk-about-stuff/topics/yak-yak-yak"
      last_response.should_not contain("Hello World")
      last_response.should contain('Yo Dawg')
    end
  end
end
