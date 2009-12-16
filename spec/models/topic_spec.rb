require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Iceberg::Topic do
  before(:each) do
    @forum = Factory.build(:forum)
    @forum.save
  end
  
  # describe "#post" do
  #   it "should create a topic with a post and update topic and forum" do
  #     # TODO add author
  #     @topic = @forum.topics.post(nil, {:title => "Hello there", :message => "Welcome to my topic"})
  #     @topic.id.should_not be_nil
  #     # @topic.
  #   end
  # end
end
