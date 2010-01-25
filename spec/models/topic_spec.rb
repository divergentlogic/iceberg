require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Iceberg::Topic do
  before(:each) do
    @board = Factory.build(:board)
    @board.save
  end
  
  # describe "#post" do
  #   it "should create a topic with a post and update topic and board" do
  #     # TODO add author
  #     @topic = @board.topics.post(nil, {:title => "Hello there", :message => "Welcome to my topic"})
  #     @topic.id.should_not be_nil
  #     # @topic.
  #   end
  # end
end
