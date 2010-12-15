require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Iceberg" do
  it "turns strings into URL slugs" do
    "Hello World".to_url.should == "hello-world"
    "Ben & Jerry's".to_url.should == "ben-and-jerrys"
    "2 + 2 = 5".to_url.should == "2-plus-2-=-5"
    "I vote +1".to_url.should == "i-vote-plus-1"
  end
end
