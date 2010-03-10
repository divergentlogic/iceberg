require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Topic" do
  describe "unique title and slug" do
    before(:each) do
      @board = Factory.create(:board)
      @topic = @board.post_topic(nil, :title => "A very special title", :message => "First post")
    end
    
    it "should complain if the title is not unique" do
      topic = @board.post_topic(nil, :title => "A very special title", :message => "Second post")
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
  
  describe "updating the title" do
    before(:each) do
      @board = Factory.create(:board)
      @topic = @board.post_topic(nil, :title => "Topic", :message => "First Post")
    end
    
    it "should not change the slug" do
      @topic.title = "New Title"
      @topic.save
      @topic.title.should == "New Title"
      @topic.slug.should  == "topic"
    end
  end
  
  describe "deleting" do
    before(:each) do
      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 1, 0, 0))
      @board = Factory.create(:board)
      @topic = @board.post_topic(nil, :title => "To be deleted", :message => "First post")
    end
    
    it "should delete in a paranoid fashion" do
      @topic.destroy
      @topic.deleted_at.should == Time.utc(2010, 1, 1, 1, 0, 0)
    end

    it "should allow titles to be reused from deleted topics" do
      @topic.destroy
      
      @new = @board.post_topic(nil, :title => "To be deleted", :message => "First post")
      @new.save.should be_true
    end
  end
  
  describe "#move_to" do
    before(:each) do
      @old_board      = Factory.create(:board, :title => "Old Board")
      @new_board      = Factory.create(:board, :title => "New Board")
      @invalid_board  = Factory.create(:board, :title => "Invalid Board", :allow_topics => false)
      
      Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 1, 0, 0))
      @author = Iceberg::App::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @topic  = @old_board.post_topic(@author, {:title => "Mover and Shaker", :message => "Move me"})
      @post   = @topic.posts.first
      
      @old_board.reload
      @new_board.reload
      @invalid_board.reload
      @topic.reload
      @post.reload
    end
    
    it "should begin with a sane state" do
      @old_board.topics.count.should                == 1
      @old_board.last_post.should                   == @post
      @old_board.last_topic.should                  == @topic
      @old_board.last_updated_at.to_s.should        == @post.updated_at.to_s
      @old_board.last_author_id.should              == 1
      @old_board.last_author_name.should            == "Billy Gnosis"
      @old_board.last_author_ip_address.to_s.should == "127.0.0.1"
      @old_board.topics_count.should                == 1
      @old_board.posts_count.should                 == 1
  
      @new_board.topics.count.should            == 0
      @new_board.last_post.should               be_nil
      @new_board.last_topic.should              be_nil
      @new_board.last_updated_at.should         be_nil
      @new_board.last_author_id.should          be_nil
      @new_board.last_author_name.should        be_nil
      @new_board.last_author_ip_address.should  be_nil
      @new_board.topics_count.should            == 0
      @new_board.posts_count.should             == 0
    end
    
    it "should move to another board" do
      @topic.board.should == @old_board
      @topic.move_to(@new_board).should be_true
      @topic.board.should == @new_board
    end
    
    it "should update the caches for the original board" do
      @topic.move_to(@new_board).should be_true
      @old_board.topics.count.should            == 0
      @old_board.last_post.should               be_nil
      @old_board.last_topic.should              be_nil
      @old_board.last_updated_at.should         be_nil
      @old_board.last_author_id.should          be_nil
      @old_board.last_author_name.should        be_nil
      @old_board.last_author_ip_address.should  be_nil
      @old_board.topics_count.should            == 0
      @old_board.posts_count.should             == 0
    end
    
    it "should update the caches for the new board" do
      @topic.move_to(@new_board).should be_true
      @new_board.topics.count.should                == 1
      @new_board.last_post.should                   == @post
      @new_board.last_topic.should                  == @topic
      @new_board.last_updated_at.to_s.should        == @post.updated_at.to_s
      @new_board.last_author_id.should              == 1
      @new_board.last_author_name.should            == "Billy Gnosis"
      @new_board.last_author_ip_address.to_s.should == "127.0.0.1"
      @new_board.topics_count.should                == 1
      @new_board.posts_count.should                 == 1
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
        @old_board.post_topic(@author, {:title => "Topic 1", :message => "Topic 1"})
        
        Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 3, 0, 0))
        @old_last_topic = @old_board.post_topic(@author, {:title => "Topic 2", :message => "Topic 2"})
        @old_last_post  = @old_last_topic.posts.first
        
        Time.stub!(:now).and_return(Time.utc(2010, 1, 1, 4, 0, 0))
        @new_last_topic = @new_board.post_topic(@author, {:title => "Topic 3", :message => "Topic 3"})
        @new_last_post  = @new_last_topic.posts.first
        
        @old_board.reload
        @new_board.reload
        @old_last_topic.reload
        @new_last_topic.reload
        @old_last_post.reload
        @new_last_post.reload
      end
      
      it "should begin with a sane state" do
        @old_board.last_post.should                   == @old_last_post
        @old_board.last_topic.should                  == @old_last_topic
        @old_board.last_updated_at.to_s.should        == @old_last_post.updated_at.to_s
        @old_board.last_author_id.should              == 1
        @old_board.last_author_name.should            == "Billy Gnosis"
        @old_board.last_author_ip_address.to_s.should == "127.0.0.1"
        @old_board.topics_count.should                == 3
        @old_board.posts_count.should                 == 3

        @new_board.last_post.should                   == @new_last_post
        @new_board.last_topic.should                  == @new_last_topic
        @new_board.last_updated_at.to_s.should        == @new_last_post.updated_at.to_s
        @new_board.last_author_id.should              == 1
        @new_board.last_author_name.should            == "Billy Gnosis"
        @new_board.last_author_ip_address.to_s.should == "127.0.0.1"
        @new_board.topics_count.should                == 1
        @new_board.posts_count.should                 == 1
      end
      
      it "should update the caches for the original board" do
        @topic.move_to(@new_board).should be_true
        @old_board.last_post.should                   == @old_last_post
        @old_board.last_topic.should                  == @old_last_topic
        @old_board.last_updated_at.should             == @old_last_post.updated_at.to_s
        @old_board.last_author_id.should              == 1
        @old_board.last_author_name.should            == "Billy Gnosis"
        @old_board.last_author_ip_address.to_s.should == "127.0.0.1"
        @old_board.topics_count.should                == 2
        @old_board.posts_count.should                 == 2
      end

      it "should update the caches for the new board" do
        @topic.move_to(@new_board).should be_true
        @new_board.last_post.should                   == @new_last_post
        @new_board.last_topic.should                  == @new_last_topic
        @new_board.last_updated_at.to_s.should        == @new_last_post.updated_at.to_s
        @new_board.last_author_id.should              == 1
        @new_board.last_author_name.should            == "Billy Gnosis"
        @new_board.last_author_ip_address.to_s.should == "127.0.0.1"
        @new_board.topics_count.should                == 2
        @new_board.posts_count.should                 == 2
      end
    end
  end
end
