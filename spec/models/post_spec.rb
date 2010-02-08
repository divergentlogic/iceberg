require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Iceberg::Post do
  describe "author" do
    before(:each) do
      @board = Factory.create(:board)
    end
    
    describe "post topic" do
      it "should not save author attributes if the author is nil" do
        topic = @board.post_topic(nil, :title => "Topic", :message => "Post")
        post = topic.posts.first
        post.author_id.should be_nil
        post.author_name.should be_nil
        post.author_ip_address.should be_nil
      end

      it "should save author attributes if the author is given" do
        author = Blank.new({:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1"})
        topic = @board.post_topic(author, :title => "Topic", :message => "Post")
        post = topic.posts.first
        post.author_id.should == 1
        post.author_name.should == "Billy Gnosis"
        post.author_ip_address.to_s.should == "127.0.0.1"
      end

      describe "partial author attributes" do
        it "should only save id" do
          author = Blank.new({:id => 1})
          topic = @board.post_topic(author, :title => "Topic", :message => "Post")
          post = topic.posts.first
          post.author_id.should == 1
          post.author_name.should be_nil
          post.author_ip_address.should be_nil
        end
        
        it "should only save name" do
          author = Blank.new({:name => "Billy Gnosis"})
          topic = @board.post_topic(author, :title => "Topic", :message => "Post")
          post = topic.posts.first
          post.author_id.should be_nil
          post.author_name.should == "Billy Gnosis"
          post.author_ip_address.should be_nil
        end
        
        it "should only save IP Address" do
          author = Blank.new({:ip_address => "127.0.0.1"})
          topic = @board.post_topic(author, :title => "Topic", :message => "Post")
          post = topic.posts.first
          post.author_id.should be_nil
          post.author_name.should be_nil
          post.author_ip_address.to_s.should == '127.0.0.1'
        end
      end
    end
    
    describe "reply to post" do
      before(:each) do
        @topic = @board.post_topic(nil, :title => "Topic", :message => "Post")
        @post = @topic.posts.first
      end
      
      it "should not save author attributes if the author is nil" do
        reply = @post.reply(nil, :message => "Reply")
        reply.save
        reply.author_id.should be_nil
        reply.author_name.should be_nil
        reply.author_ip_address.should be_nil
      end

      it "should save author attributes if the author is given" do
        author = Blank.new({:id => 1, :name => "Billy Gnosis", :ip_address => "127.0.0.1"})
        reply = @post.reply(author, :message => "Reply")
        reply.save
        reply.author_id.should == 1
        reply.author_name.should == "Billy Gnosis"
        reply.author_ip_address.to_s.should == "127.0.0.1"
      end

      describe "partial author attributes" do
        it "should only save id" do
          author = Blank.new({:id => 1})
          reply = @post.reply(author, :message => "Reply")
          reply.save
          reply.author_id.should == 1
          reply.author_name.should be_nil
          reply.author_ip_address.should be_nil
        end
        
        it "should only save name" do
          author = Blank.new({:name => "Billy Gnosis"})
          reply = @post.reply(author, :message => "Reply")
          reply.save
          reply.author_id.should be_nil
          reply.author_name.should == "Billy Gnosis"
          reply.author_ip_address.should be_nil
        end
        
        it "should only save IP Address" do
          author = Blank.new({:ip_address => "127.0.0.1"})
          reply = @post.reply(author, :message => "Reply")
          reply.save
          reply.author_id.should be_nil
          reply.author_name.should be_nil
          reply.author_ip_address.to_s.should == '127.0.0.1'
        end
      end
    end
  end
end
