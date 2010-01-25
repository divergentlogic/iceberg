require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "getting /boards" do
  before(:each) do
    @root     = Factory.build(:board, :title => "Root")
    @root.save
    @general  = Factory.build(:board, :title => "General", :parent => @root)
    @general.save
    @carriers = Factory.build(:board, :title => "Carriers", :parent => @root)
    @carriers.save
    @att      = Factory.build(:board, :title => "AT&T", :parent => @carriers)
    @att.save
    @sprint   = Factory.build(:board, :title => "Sprint", :parent => @carriers)
    @sprint.save
    @verizon  = Factory.build(:board, :title => "Verizon", :parent => @carriers)
    @verizon.save
  end
  
  it "should retrieve the index page" do
    get "/boards"
    last_response.should be_ok
  end
  
  it "should return 404 for slugs that don't match to a board" do
    get "/boards/not-a-slug"
    last_response.should be_not_found
  end
  
  it "should display link to create a new topic if the board allows topics" do
    @board = Factory.build(:board, :title => "Fun Stuff", :parent => @root, :allow_topics => true)
    @board.save
    
    get "/boards/root/fun-stuff"
    last_response.should have_selector(".board_controls > a:contains('New Topic')")
  end
  
  it "should not display link to create a new topic if the board does not allows topics" do
    @board = Factory.build(:board, :title => "Fun Stuff", :parent => @root, :allow_topics => false)
    @board.save
    
    get "/boards/root/fun-stuff"
    last_response.should_not have_selector(".board_controls > a:contains('New Topic')")
  end
end
