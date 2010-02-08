require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Iceberg::Topic do
  describe "#move_to" do
    before(:each) do
      @old_board      = Factory.create(:board, :title => "Old Board")
      @new_board      = Factory.create(:board, :title => "New Board")
      @invalid_board  = Factory.create(:board, :title => "Invalid Board", :allow_topics => false)

      @author = Iceberg::Author.new(:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1")
      @topic  = @old_board.post_topic(@author, {:title => "Mover and Shaker", :message => "Move me"})
      @post   = @topic.posts.first
    end
    
    it "should begin with a sane state" do
      @old_board.last_post.should                   == @post
      @old_board.last_topic.should                  == @topic
      @old_board.last_updated_at.to_s.should        == @post.updated_at.to_s
      @old_board.last_author_id.should              == 1
      @old_board.last_author_name.should            == "Billy Gnosis"
      @old_board.last_author_ip_address.to_s.should == "127.0.0.1"
      @old_board.topics_count.should                == 1
      @old_board.posts_count.should                 == 1

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
  end
end
