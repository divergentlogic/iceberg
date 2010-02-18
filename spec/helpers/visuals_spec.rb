require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class TestApp < Iceberg::App
  get %r{/breadcrumbs/(board|topic)/([1-9][0-9]*)} do |type, id|
    item = type == 'board' ? Board.get(id) : Topic.get(id)
    options = {}
    options[:separator]     = params[:separator]            if params[:separator]
    options[:wrap_with_tag] = params[:wrap_with_tag].to_sym if params[:wrap_with_tag]
    breadcrumbs(item, options)
  end
end

describe Iceberg::Helpers::Visuals do
  describe "#breadcrumbs" do
    before(:each) do
      @root     = Factory.create(:board, :title => "Root")
      @animals  = Factory.create(:board, :title => "Animals", :parent => @root)
      @bears    = Factory.create(:board, :title => "Bears",   :parent => @animals)
      @topic    = @bears.post_topic(nil, :title => "Watch out", :message => "Bears will eat your face off")
    end
    
    it "should display a trail of links for a board" do
      get "/breadcrumbs/board/#{@bears.id}"
      last_response.body.should == %{<a href="/boards">Index</a> &gt; <a href="/boards/root">Root</a> &gt; <a href="/boards/root/animals">Animals</a> &gt; <a href="/boards/root/animals/bears">Bears</a>}
    end
    
    it "should display a trail of links for a topic" do
      get "/breadcrumbs/topic/#{@topic.id}"
      last_response.body.should == %{<a href="/boards">Index</a> &gt; <a href="/boards/root">Root</a> &gt; <a href="/boards/root/animals">Animals</a> &gt; <a href="/boards/root/animals/bears">Bears</a> &gt; <a href="/boards/root/animals/bears/topics/watch-out">Watch out</a>}
    end
    
    it "should display a trail of links with the supplied separator" do
      get "/breadcrumbs/board/#{@animals.id}?separator=+%7C+"
      last_response.body.should == %{<a href="/boards">Index</a> | <a href="/boards/root">Root</a> | <a href="/boards/root/animals">Animals</a>}
    end
    
    it "should wrap links in supplied tag" do
      get "/breadcrumbs/board/#{@animals.id}?separator=&wrap_with_tag=li"
      last_response.body.should == %{<li><a href="/boards">Index</a></li><li><a href="/boards/root">Root</a></li><li><a href="/boards/root/animals">Animals</a></li>}
    end
  end
end
