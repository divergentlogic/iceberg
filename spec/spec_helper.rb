ENV['RACK_ENV'] ||= 'test'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'iceberg'
require 'sinatra'
require 'spec'
require 'spec/autorun'
require 'spec/interop/test'
require 'rack/test'
require 'webrat'
require 'factory_girl'
require 'be_valid_asset'

Dir[File.expand_path(File.join(File.dirname(__FILE__), 'support', '**', '*.rb'))].each {|f| require f}

Iceberg::App.set :environment, :test
Iceberg::App.set :run, false
Iceberg::App.set :raise_errors, true
Iceberg::App.set :logging, false

class Blank
  instance_methods.each { |m| undef_method m unless m =~ /^__/ || m =~ /^class$/ || m =~ /^respond_to?/ }
  
  def initialize(table)
    throw ArgumentError.new("must be a hash") unless table.is_a?(Hash)
    defs = table.map do |k, v|
      "attr_accessor :#{k.to_s}"
    end
    self.class.class_eval defs.join("\n")
    table.each do |k, v|
      __send__(:"#{k}=", v)
    end
  end
end

Spec::Runner.configure do |config|
  def app
    @app ||= Rack::Builder.app do
      use Rack::Session::Cookie
      run Iceberg::App
    end
  end
    
  config.include(Rack::Test::Methods)
  config.include(Webrat::Matchers)
  config.include(CustomMatchers)
  
  config.before(:each) do
    DataMapper.setup(:default, 'sqlite3::memory:')
    DataMapper.auto_migrate!
  end
end
