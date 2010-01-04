require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "getting /forums" do
  before(:each) do
    @root     = Factory.build(:forum, :title => "Root")
    @root.save
    @general  = Factory.build(:forum, :title => "General", :parent => @root)
    @general.save
    @carriers = Factory.build(:forum, :title => "Carriers", :parent => @root)
    @carriers.save
    @att      = Factory.build(:forum, :title => "AT&T", :parent => @carriers)
    @att.save
    @sprint   = Factory.build(:forum, :title => "Sprint", :parent => @carriers)
    @sprint.save
    @verizon  = Factory.build(:forum, :title => "Verizon", :parent => @carriers)
    @verizon.save
  end
  
  it "should retrieve the index page" do
    get "/forums"
    last_response.should be_ok
  end
  
  it "should return 404 for slugs that don't match to a forum" do
    get "/forums/not-a-slug"
    last_response.should be_not_found
  end
  
  it "should display link to create a new topic if the forum allows topics" do
    @forum = Factory.build(:forum, :title => "Fun Stuff", :parent => @root, :allow_topics => true)
    @forum.save
    
    get "/forums/root/fun-stuff"
    last_response.should have_selector(".forum_controls > a:contains('New Topic')")
  end
  
  it "should not display link to create a new topic if the forum does not allows topics" do
    @forum = Factory.build(:forum, :title => "Fun Stuff", :parent => @root, :allow_topics => false)
    @forum.save
    
    get "/forums/root/fun-stuff"
    last_response.should_not have_selector(".forum_controls > a:contains('New Topic')")
  end
end
