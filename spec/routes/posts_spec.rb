require File.dirname(__FILE__) + '/../spec_helper'

describe Iceberg::Routes::Posts do
  describe "getting a new post" do
    before(:each) do
      @board = Factory.build(:board, :title => "Board")
      @board.save
      
      # TODO add author
      @topic = @board.post_topic(nil, {:title => "Topic", :message => "Discuss"})
      @post = @topic.posts.first
    end
    
    it "should be successful without quoting" do
      get "/boards/board/topics/topic/reply/#{@post.id}"
      last_response.should be_ok
      last_response.body.should_not have_selector("textarea:contains('Discuss')")
    end
    
    it "should be successful with quoting" do
      get "/boards/board/topics/topic/reply/#{@post.id}?quote=true"
      last_response.should be_ok
      last_response.body.should have_selector("textarea:contains('Discuss')")
    end
  end
end
