require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Topic" do
  describe "unique title and slug" do
    before(:each) do
      @board = TestApp::Board.generate
      @topic = @board.post_topic(nil, :title => "A very special title", :message => "First post")
    end

    it "should complain if the title is not unique" do
      topic = @board.post_topic(nil, :title => "A very special title", :message => "Second post")
      topic.valid?
      topic.should be_new
      topic.should error_on(:title)
      topic.errors.on(:title).should == ["A topic with that title has been posted in this board already; maybe you'd like to post under that topic instead?"]
      topic.existing_topic.should == @topic
    end

    it "should complain if the slug is not unique" do
      topic = @board.post_topic(nil, :title => "A (very) special title", :message => "Second post")
      topic.should be_new
      topic.should error_on(:slug)
      topic.errors.on(:slug).should == ["A topic with that title has been posted in this board already; maybe you'd like to post under that topic instead?"]
      topic.existing_topic.should == @topic
    end
  end

  describe "user" do
    before(:each) do
      @board = TestApp::Board.generate
    end

    it "should fill out the user attributes" do
      user = Iceberg::App::User.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      topic = @board.post_topic(user, :title => "A very special title", :message => "First post")
      topic.user_id.should         == 1
      topic.user_name.should       == "Billy Gnosis"
      topic.user_ip_address.should == "127.0.0.1"
    end

    it "should leave the user attributes nil if no user is given" do
      topic = @board.post_topic(nil, :title => "A very special title", :message => "First post")
      topic.user_id.should         be_nil
      topic.user_name.should       be_nil
      topic.user_ip_address.should be_nil
    end
  end

  describe "updating the title" do
    before(:each) do
      @board = TestApp::Board.generate
      @topic = @board.post_topic(nil, :title => "Topic", :message => "First Post")
    end

    it "should change the title and slug" do
      @topic.title = "New Title"
      @topic.save
      @topic.title.should == "New Title"
      @topic.slug.should  == "new-title"
    end
  end

  describe "view!" do
    before(:each) do
      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 1, 0, 0))
      @board = TestApp::Board.generate
      @topic = @board.post_topic(nil, :title => "Topic", :message => "First Post")
    end

    it "should not have any views on creation" do
      @topic.view_count.should == 0
      @topic.views.should      be_empty
    end

    describe "with a user" do
      before(:each) do
        @user = Iceberg::App::User.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
        @topic.view!(@user)
      end

      it "should update the view count" do
        @topic.view_count.should == 1
      end

      it "should create a view" do
        @topic.should have(1).views
      end

      it "should time stamp the view" do
        view = @topic.views.first
        view.created_at.should == Time.utc(2010, 1, 1, 1, 0, 0)
      end

      it "should create a view with user attributes" do
        view = @topic.views.first
        view.user_id.should         == 1
        view.user_name.should       == "Billy Gnosis"
        view.user_ip_address.should == "127.0.0.1"
      end
    end

    describe "without a user" do
      before(:each) do
        @topic.view!
      end

      it "should update the view count" do
        @topic.view_count.should == 1
      end

      it "should create a view" do
        @topic.should have(1).views
      end

      it "should time stamp the view" do
        view = @topic.views.first
        view.created_at.should == Time.utc(2010, 1, 1, 1, 0, 0)
      end

      it "should create a view with user attributes" do
        view = @topic.views.first
        view.user_id.should         be_nil
        view.user_name.should       be_nil
        view.user_ip_address.should be_nil
      end
    end
  end

  describe "deleting" do
    before(:each) do
      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 1, 0, 0))
      @board = TestApp::Board.generate
      @topic = @board.post_topic(nil, :title => "To be deleted", :message => "First post")
    end

    it "should delete in a paranoid fashion" do
      @topic.destroy.should_not be_false
      @topic.deleted_at.should == Time.utc(2010, 1, 1, 1, 0, 0)
    end

    it "should allow titles to be reused from deleted topics" do
      @topic.destroy.should_not be_false

      @new = @board.post_topic(nil, :title => "To be deleted", :message => "First post")
      @new.save.should be_true
    end

    it "should delete all posts" do
      @topic.posts.first.reply(nil, :message => "Second post")
      @topic.posts.reload

      post1 = @topic.posts.first
      post2 = @topic.posts.last

      @topic.destroy.should_not be_false
      post1.deleted_at.should == Time.utc(2010, 1, 1, 1, 0, 0)
      post2.deleted_at.should == Time.utc(2010, 1, 1, 1, 0, 0)
    end

    it "should delete all views" do
      3.times { @topic.view! }
      @topic.should have(3).views
      @topic.destroy
      @topic.should have(0).views
    end
  end

  describe "#move_to" do
    before(:each) do
      @old_board      = TestApp::Board.generate(:title => "Old Board")
      @new_board      = TestApp::Board.generate(:title => "New Board")
      @invalid_board  = TestApp::Board.generate(:title => "Invalid Board", :allow_topics => false)

      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 1, 0, 0))
      @user  = Iceberg::App::User.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @topic = @old_board.post_topic(@user, {:title => "Mover and Shaker", :message => "Move me"})
      @post  = @topic.posts.first

      @old_board.reload
      @new_board.reload
      @invalid_board.reload
      @topic.reload
      @post.reload
    end

    it "should begin with a sane state" do
      @old_board.topics.count.should              == 1
      @old_board.last_post.should                 == @post
      @old_board.last_topic.should                == @topic
      @old_board.last_updated_at.to_s.should      == @post.updated_at.to_s
      @old_board.last_user_id.should              == 1
      @old_board.last_user_name.should            == "Billy Gnosis"
      @old_board.last_user_ip_address.to_s.should == "127.0.0.1"
      @old_board.topics_count.should              == 1
      @old_board.posts_count.should               == 1

      @new_board.topics.count.should          == 0
      @new_board.last_post.should             be_nil
      @new_board.last_topic.should            be_nil
      @new_board.last_updated_at.should       be_nil
      @new_board.last_user_id.should          be_nil
      @new_board.last_user_name.should        be_nil
      @new_board.last_user_ip_address.should  be_nil
      @new_board.topics_count.should          == 0
      @new_board.posts_count.should           == 0
    end

    it "should move to another board" do
      @topic.board.should == @old_board
      @topic.move_to(@new_board).should be_true
      @topic.board.should == @new_board
    end

    it "should update the caches for the original board" do
      @topic.move_to(@new_board).should be_true
      @old_board.reload
      @old_board.topics.count.should          == 0
      @old_board.last_post.should             be_nil
      @old_board.last_topic.should            be_nil
      @old_board.last_updated_at.should       be_nil
      @old_board.last_user_id.should          be_nil
      @old_board.last_user_name.should        be_nil
      @old_board.last_user_ip_address.should  be_nil
      @old_board.topics_count.should          == 0
      @old_board.posts_count.should           == 0
    end

    it "should update the caches for the new board" do
      @topic.move_to(@new_board).should be_true
      @new_board.reload
      @new_board.topics.count.should              == 1
      @new_board.last_post.should                 == @post
      @new_board.last_topic.should                == @topic
      @new_board.last_updated_at.to_s.should      == @post.updated_at.to_s
      @new_board.last_user_id.should              == 1
      @new_board.last_user_name.should            == "Billy Gnosis"
      @new_board.last_user_ip_address.to_s.should == "127.0.0.1"
      @new_board.topics_count.should              == 1
      @new_board.posts_count.should               == 1
    end

    it "should not move to a board that does not allow topics" do
      @topic.move_to(@invalid_board).should be_false
      @topic.should error_on(:board)
    end

    it "should not move to the same board" do
      @topic.move_to(@old_board).should be_false
    end

    describe "with many topics" do
      before(:each) do
        Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 2, 0, 0))
        @old_board.post_topic(@user, {:title => "Topic 1", :message => "Topic 1"})

        Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 3, 0, 0))
        @old_last_topic = @old_board.post_topic(@user, {:title => "Topic 2", :message => "Topic 2"})
        @old_last_post  = @old_last_topic.posts.first

        Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 4, 0, 0))
        @new_last_topic = @new_board.post_topic(@user, {:title => "Topic 3", :message => "Topic 3"})
        @new_last_post  = @new_last_topic.posts.first

        @old_board.reload
        @new_board.reload
        @old_last_topic.reload
        @new_last_topic.reload
        @old_last_post.reload
        @new_last_post.reload
      end

      it "should begin with a sane state" do
        @old_board.last_post.should                 == @old_last_post
        @old_board.last_topic.should                == @old_last_topic
        @old_board.last_updated_at.to_s.should      == @old_last_post.updated_at.to_s
        @old_board.last_user_id.should              == 1
        @old_board.last_user_name.should            == "Billy Gnosis"
        @old_board.last_user_ip_address.to_s.should == "127.0.0.1"
        @old_board.topics_count.should              == 3
        @old_board.posts_count.should               == 3

        @new_board.last_post.should                 == @new_last_post
        @new_board.last_topic.should                == @new_last_topic
        @new_board.last_updated_at.to_s.should      == @new_last_post.updated_at.to_s
        @new_board.last_user_id.should              == 1
        @new_board.last_user_name.should            == "Billy Gnosis"
        @new_board.last_user_ip_address.to_s.should == "127.0.0.1"
        @new_board.topics_count.should              == 1
        @new_board.posts_count.should               == 1
      end

      it "should update the caches for the original board" do
        @topic.move_to(@new_board).should be_true
        @old_board.reload
        @old_board.last_post.should                 == @old_last_post
        @old_board.last_topic.should                == @old_last_topic
        @old_board.last_updated_at.to_s.should      == @old_last_post.updated_at.to_s
        @old_board.last_user_id.should              == 1
        @old_board.last_user_name.should            == "Billy Gnosis"
        @old_board.last_user_ip_address.to_s.should == "127.0.0.1"
        @old_board.topics_count.should              == 2
        @old_board.posts_count.should               == 2
      end

      it "should update the caches for the new board" do
        @topic.move_to(@new_board).should be_true
        @new_board.reload
        @new_board.last_post.should                 == @new_last_post
        @new_board.last_topic.should                == @new_last_topic
        @new_board.last_updated_at.to_s.should      == @new_last_post.updated_at.to_s
        @new_board.last_user_id.should              == 1
        @new_board.last_user_name.should            == "Billy Gnosis"
        @new_board.last_user_ip_address.to_s.should == "127.0.0.1"
        @new_board.topics_count.should              == 2
        @new_board.posts_count.should               == 2
      end
    end
  end
end
