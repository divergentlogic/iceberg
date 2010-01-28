require File.dirname(__FILE__) + '/../spec_helper'

describe Iceberg::Routes::Topics do
  describe "moving a topic" do
    before(:each) do
      @original_board = Factory.create(:board, :title => "Original Board")
      # TODO add author
      @topic = @original_board.post_topic(nil, {:title => "My Topic", :message => "Move me"})
      @valid_board1 = Factory.create(:board, :title => "Valid Board 1")
      @valid_board2 = Factory.create(:board, :title => "Valid Board 2")
      @invalid_board = Factory.create(:board, :title => "Invalid Board", :allow_topics => false)
    end
    
    describe "GET" do
      it "should be successful" do
        get "/topics/#{@topic.id}/move"
        last_response.should be_ok
      end
      
      it "should not match on non numeric parameters" do
        get "/topics/something-non-numeric/move"
        last_response.should be_not_found
      end
      
      it "should not match on IDs that begin with 0" do
        get "/topics/01/move"
        last_response.should be_not_found
      end
      
      it "should return 404 if the topic is not found" do
        get "/topics/99999999/move"
        last_response.should be_not_found
      end
      
      it "should display the title of the current board" do
        get "/topics/#{@topic.id}/move"
        last_response.body.should contain("Original Board")
      end
      
      it "should display the title of the topic" do
        get "/topics/#{@topic.id}/move"
        last_response.body.should contain("My Topic")
      end
      
      it "should have a form posting to the same action" do
        get "/topics/#{@topic.id}/move"
        last_response.body.should have_selector("form[action='/topics/#{@topic.id}/move'][method='post']")
      end
      
      it "should display a drop down of boards I can move the topic to" do
        get "/topics/#{@topic.id}/move"
        last_response.body.should have_selector("select > option[value='#{@valid_board1.id}']:contains('#{@valid_board1.title}')")
        last_response.body.should have_selector("select > option[value='#{@valid_board2.id}']:contains('#{@valid_board2.title}')")
      end
      
      it "should not display the topic's current board in the drop down" do
        get "/topics/#{@topic.id}/move"
        last_response.body.should_not have_selector("select > option[value='#{@original_board.id}']:contains('#{@original_board.title}')")
      end
      
      it "should not display boards that don't allow topics" do
        get "/topics/#{@topic.id}/move"
        last_response.body.should_not have_selector("select > option[value='#{@invalid_board.id}']:contains('#{@invalid_board.title}')")
      end
    end

    describe "POST" do
      it "should be successful" do
        post "/topics/#{@topic.id}/move", {'iceberg-topic' => {'board_id' => @valid_board1.id}}
        follow_redirect!
        last_response.should be_ok
      end
      
      it "should not match on non numeric parameters" do
        post "/topics/something-non-numeric/move"
        last_response.should be_not_found
      end
      
      it "should not match on IDs that begin with 0" do
        post "/topics/01/move"
        last_response.should be_not_found
      end
      
      it "should return 404 if the topic is not found" do
        post "/topics/99999999/move"
        last_response.should be_not_found
      end
      
      it "should not be successful if the board does not allow topics" do
        post "/topics/#{@topic.id}/move", {'iceberg-topic' => {'board_id' => @invalid_board.id}}
        last_response.body.should contain("This board does not allow topics")
      end
      
      it "should redirect to the topic page if successful" do
        post "/topics/#{@topic.id}/move", {'iceberg-topic' => {'board_id' => @valid_board1.id}}
        follow_redirect!
        last_request.path.should == "/boards/valid-board-1/topics/my-topic"
        last_response.body.should contain(@valid_board1.title)
      end
    end
  end
end
