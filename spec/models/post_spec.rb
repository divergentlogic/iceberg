require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Post" do
  it "should delete in a paranoid fashion" do
    Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 1, 0, 0))
    @board = Factory.create(:board)
    @topic = @board.post_topic(nil, :title => "Topic 1", :message => "First post")
    @post  = @topic.posts.first

    @post.destroy
    @post.deleted_at.should == Time.utc(2010, 1, 1, 1, 0, 0)
  end

  describe "reply" do
    before(:each) do
      @author1  = Iceberg::App::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @author2  = Iceberg::App::Author.new(:id => 2, :name => "Brett Gurewitz", :ip_address => "192.168.1.1")
      @board    = Factory.create(:board)

      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 6, 0, 0))
      @topic    = @board.post_topic(@author1, :title => "Topic", :message => "First Post")
      @post1    = @topic.posts.first

      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 7, 0, 0))
      @post2    = @post1.reply(@author2, :message => "Second Post")
      @post2.save
    end

    it "should be successful" do
      @post2.errors.should  be_empty
      @post2.new?.should    be_false
      @post2.id.should_not  be_nil
    end

    it "should update the topic cache" do
      @topic.last_post.id.should                == @post2.id
      @topic.last_updated_at.to_s.should        == @post2.updated_at.to_s
      @topic.last_author_id.should              == 2
      @topic.last_author_name.should            == "Brett Gurewitz"
      @topic.last_author_ip_address.to_s.should == "192.168.1.1"
      @topic.posts_count.should                 == 2
    end

    it "should update the board cache" do
      @board.last_post.id.should                == @post2.id
      @board.last_topic.should                  == @topic
      @board.last_updated_at.to_s.should        == @post2.updated_at.to_s
      @board.last_author_id.should              == 2
      @board.last_author_name.should            == "Brett Gurewitz"
      @board.last_author_ip_address.to_s.should == "192.168.1.1"
      @board.topics_count.should                == 1
      @board.posts_count.should                 == 2
    end

    it "should not be successful if the topic is locked" do
      @topic.locked = true
      @topic.save

      reply = @post2.reply(@author1, :message => "Can't post to a locked topic")
      reply.valid?.should be_false
      reply.should error_on(:topic)
    end
  end

  describe "author" do
    before(:each) do
      @board = Factory.create(:board)
      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 6, 0, 0))
    end

    describe "post topic" do
      it "should not save author attributes if the author is nil" do
        topic = @board.post_topic(nil, :title => "Topic", :message => "Post")
        post  = topic.posts.first
        post.author_id.should         be_nil
        post.author_name.should       be_nil
        post.author_ip_address.should be_nil
      end

      it "should save author attributes if the author is given" do
        author  = Iceberg::App::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
        topic   = @board.post_topic(author, :title => "Topic", :message => "Post")
        post    = topic.posts.first
        post.author_id.should               == 1
        post.author_name.should             == "Billy Gnosis"
        post.author_ip_address.to_s.should  == "127.0.0.1"
      end

      describe "partial author attributes" do
        it "should only save id" do
          author  = Iceberg::App::Author.new(:id => 1)
          topic   = @board.post_topic(author, :title => "Topic", :message => "Post")
          post    = topic.posts.first
          post.author_id.should         == 1
          post.author_name.should       be_nil
          post.author_ip_address.should be_nil
        end

        it "should only save name" do
          author  = Iceberg::App::Author.new(:name => "Billy Gnosis")
          topic   = @board.post_topic(author, :title => "Topic", :message => "Post")
          post    = topic.posts.first
          post.author_id.should         be_nil
          post.author_name.should       == "Billy Gnosis"
          post.author_ip_address.should be_nil
        end

        it "should only save IP Address" do
          author  = Iceberg::App::Author.new(:ip_address => "127.0.0.1")
          topic   = @board.post_topic(author, :title => "Topic", :message => "Post")
          post    = topic.posts.first
          post.author_id.should               be_nil
          post.author_name.should             be_nil
          post.author_ip_address.to_s.should  == '127.0.0.1'
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

      it "should not save author attributes if the author is nil" do
        reply = @post.reply(nil, :message => "Reply")
        reply.save
        reply.author_id.should          be_nil
        reply.author_name.should        be_nil
        reply.author_ip_address.should  be_nil
      end

      it "should save author attributes if the author is given" do
        author  = Iceberg::App::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
        reply   = @post.reply(author, :message => "Reply")
        reply.save
        reply.author_id.should              == 1
        reply.author_name.should            == "Billy Gnosis"
        reply.author_ip_address.to_s.should == "127.0.0.1"
      end

      describe "partial author attributes" do
        it "should only save id" do
          author  = Iceberg::App::Author.new(:id => 1)
          reply   = @post.reply(author, :message => "Reply")
          reply.save
          reply.author_id.should          == 1
          reply.author_name.should        be_nil
          reply.author_ip_address.should  be_nil
        end

        it "should only save name" do
          author  = Iceberg::App::Author.new(:name => "Billy Gnosis")
          reply   = @post.reply(author, :message => "Reply")
          reply.save
          reply.author_id.should          be_nil
          reply.author_name.should        == "Billy Gnosis"
          reply.author_ip_address.should  be_nil
        end

        it "should only save IP Address" do
          author  = Iceberg::App::Author.new(:ip_address => "127.0.0.1")
          reply   = @post.reply(author, :message => "Reply")
          reply.save
          reply.author_id.should              be_nil
          reply.author_name.should            be_nil
          reply.author_ip_address.to_s.should == '127.0.0.1'
        end
      end
    end
  end
end
