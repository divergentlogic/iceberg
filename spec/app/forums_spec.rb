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
end