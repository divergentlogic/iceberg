require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Iceberg::Helpers::Visuals do
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
  
  describe "#breadcrumbs" do
    it "should display a trail of links" do
      breadcrumbs(@verizon).should == %{<a href="/boards">Index</a> &gt; <a href="/boards/root">Root</a> &gt; <a href="/boards/root/carriers">Carriers</a> &gt; <a href="/boards/root/carriers/verizon">Verizon</a>}
    end
    
    it "should display a trail of links with the supplied separator" do
      breadcrumbs(@verizon, :separator => " | ").should == %{<a href="/boards">Index</a> | <a href="/boards/root">Root</a> | <a href="/boards/root/carriers">Carriers</a> | <a href="/boards/root/carriers/verizon">Verizon</a>}
    end
    
    it "should wrap links in supplied tag" do
      breadcrumbs(@verizon, :separator => "", :wrap_with_tag => :li).should == %{<li><a href="/boards">Index</a></li><li><a href="/boards/root">Root</a></li><li><a href="/boards/root/carriers">Carriers</a></li><li><a href="/boards/root/carriers/verizon">Verizon</a></li>}
    end
  end
end
