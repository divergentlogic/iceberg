require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sinatra::Iceberg::Forums::Helpers do
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
  
  describe "#breadcrumbs" do
    it "should display a trail of links" do
      breadcrumbs(@verizon).should == %{<a href="/forums">Index</a> &gt; <a href="/forums/root">Root</a> &gt; <a href="/forums/root/carriers">Carriers</a> &gt; <a href="/forums/root/carriers/verizon">Verizon</a>}
    end
    
    it "should display a trail of links with the supplied separator" do
      breadcrumbs(@verizon, :separator => " | ").should == %{<a href="/forums">Index</a> | <a href="/forums/root">Root</a> | <a href="/forums/root/carriers">Carriers</a> | <a href="/forums/root/carriers/verizon">Verizon</a>}
    end
    
    it "should wrap links in supplied tag" do
      breadcrumbs(@verizon, :separator => "", :wrap_with_tag => :li).should == %{<li><a href="/forums">Index</a></li><li><a href="/forums/root">Root</a></li><li><a href="/forums/root/carriers">Carriers</a></li><li><a href="/forums/root/carriers/verizon">Verizon</a></li>}
    end
  end
end
