require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Move" do
  it "should save with valid attributes" do
    @move = TestApp::Move.generate
    @move.save.should be_true
  end

  [:board_path, :topic_slug, :topic].each do |field|
    it "should validate presence of #{field}" do
      @move = TestApp::Move.generate(field => nil)
      @move.valid?
      @move.should error_on(field)
    end
  end
end
