require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Post" do
  describe "deleting" do
    before(:each) do
      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 1, 0, 0))
      @board = TestApp::Board.generate
      @topic = @board.post_topic(nil, :title => "Topic 1", :message => "First post")
      @post  = @topic.posts.first
    end

    it "should delete in a paranoid fashion" do
      @post.destroy.should_not be_false
      @post.deleted_at.should == Time.utc(2010, 1, 1, 1, 0, 0)
    end

    it "should move its replies underneath its parent" do
      reply1 = @post.reply(nil, :message => 'Reply 1')
      reply2 = reply1.reply(nil, :message => 'Reply 2')

      reply1.destroy.should_not be_false
      reply1.deleted_at.should == Time.utc(2010, 1, 1, 1, 0, 0)

      reply2.deleted_at.should be_nil
      reply2.parent.should == @post
    end
  end

  describe "reply" do
    before(:each) do
      @user1 = Iceberg::App::User.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @user2 = Iceberg::App::User.new(:id => 2, :name => "Brett Gurewitz", :ip_address => "192.168.1.1")
      @board = TestApp::Board.generate

      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 6, 0, 0))
      @topic = @board.post_topic(@user1, :title => "Topic", :message => "First Post")
      @post1 = @topic.posts.first

      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 7, 0, 0))
      @post2 = @post1.reply(@user2, :message => "Second Post")

      @board.reload
      @topic.reload
    end

    it "should be successful" do
      @post2.errors.should  be_empty
      @post2.new?.should    be_false
      @post2.id.should_not  be_nil
    end

    it "should update the topic cache" do
      @topic.last_post.should                 == @post2
      @topic.last_updated_at.to_s.should      == @post2.updated_at.to_s
      @topic.last_user_id.should              == 2
      @topic.last_user_name.should            == "Brett Gurewitz"
      @topic.last_user_ip_address.to_s.should == "192.168.1.1"
      @topic.posts_count.should               == 2
    end

    it "should update the board cache" do
      @board.last_post.should                 == @post2
      @board.last_topic.should                == @topic
      @board.last_updated_at.to_s.should      == @post2.updated_at.to_s
      @board.last_user_id.should              == 2
      @board.last_user_name.should            == "Brett Gurewitz"
      @board.last_user_ip_address.to_s.should == "192.168.1.1"
      @board.topics_count.should              == 1
      @board.posts_count.should               == 2
    end

    it "should not be successful if the topic is locked" do
      @topic.locked = true
      @topic.save

      reply = @post2.reply(@user1, :message => "Can't post to a locked topic")
      reply.should error_on(:topic)
    end
  end

  describe "user" do
    before(:each) do
      @board = TestApp::Board.generate
      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 6, 0, 0))
    end

    describe "post topic" do
      it "should not save user attributes if the user is nil" do
        topic = @board.post_topic(nil, :title => "Topic", :message => "Post")
        post  = topic.posts.first
        post.user_id.should         be_nil
        post.user_name.should       be_nil
        post.user_ip_address.should be_nil
      end

      it "should save user attributes if the user is given" do
        user  = Iceberg::App::User.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
        topic = @board.post_topic(user, :title => "Topic", :message => "Post")
        post  = topic.posts.first
        post.user_id.should               == 1
        post.user_name.should             == "Billy Gnosis"
        post.user_ip_address.to_s.should  == "127.0.0.1"
      end

      describe "partial user attributes" do
        it "should only save id" do
          user  = Iceberg::App::User.new(:id => 1)
          topic = @board.post_topic(user, :title => "Topic", :message => "Post")
          post  = topic.posts.first
          post.user_id.should         == 1
          post.user_name.should       be_nil
          post.user_ip_address.should be_nil
        end

        it "should only save name" do
          user  = Iceberg::App::User.new(:name => "Billy Gnosis")
          topic = @board.post_topic(user, :title => "Topic", :message => "Post")
          post  = topic.posts.first
          post.user_id.should         be_nil
          post.user_name.should       == "Billy Gnosis"
          post.user_ip_address.should be_nil
        end

        it "should only save IP Address" do
          user  = Iceberg::App::User.new(:ip_address => "127.0.0.1")
          topic = @board.post_topic(user, :title => "Topic", :message => "Post")
          post  = topic.posts.first
          post.user_id.should               be_nil
          post.user_name.should             be_nil
          post.user_ip_address.to_s.should  == '127.0.0.1'
        end
      end
    end

    describe "reply to post" do
      before(:each) do
        Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 6, 0, 0))
        @topic  = @board.post_topic(nil, :title => "Topic", :message => "Post")
        @post   = @topic.posts.first
        Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 7, 0, 0))
      end

      it "should not save user attributes if the user is nil" do
        reply = @post.reply(nil, :message => "Reply")
        reply.user_id.should          be_nil
        reply.user_name.should        be_nil
        reply.user_ip_address.should  be_nil
      end

      it "should save user attributes if the user is given" do
        user  = Iceberg::App::User.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
        reply = @post.reply(user, :message => "Reply")
        reply.user_id.should              == 1
        reply.user_name.should            == "Billy Gnosis"
        reply.user_ip_address.to_s.should == "127.0.0.1"
      end

      describe "partial user attributes" do
        it "should only save id" do
          user  = Iceberg::App::User.new(:id => 1)
          reply = @post.reply(user, :message => "Reply")
          reply.user_id.should          == 1
          reply.user_name.should        be_nil
          reply.user_ip_address.should  be_nil
        end

        it "should only save name" do
          user  = Iceberg::App::User.new(:name => "Billy Gnosis")
          reply = @post.reply(user, :message => "Reply")
          reply.user_id.should          be_nil
          reply.user_name.should        == "Billy Gnosis"
          reply.user_ip_address.should  be_nil
        end

        it "should only save IP Address" do
          user  = Iceberg::App::User.new(:ip_address => "127.0.0.1")
          reply = @post.reply(user, :message => "Reply")
          reply.user_id.should              be_nil
          reply.user_name.should            be_nil
          reply.user_ip_address.to_s.should == '127.0.0.1'
        end
      end
    end
  end
end
