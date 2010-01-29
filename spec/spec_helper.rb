ENV['RACK_ENV'] ||= 'test'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'iceberg'
require 'sinatra'
require 'warden'
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

Spec::Runner.configure do |config|
  class User
    attr_accessor :id, :email
    
    def initialize(id, email)
      @id = id
      @email = email
    end
  end
  
  Warden::Strategies.add(:test) do
    def authenticate!
      success!(User.new(1, 'test@example.com'))
    end
  end
  
  def app
    @app ||= Rack::Builder.app do
      use Rack::Session::Cookie
      use Warden::Manager do |manager|
        manager.default_strategies :test
        manager.failure_app = lambda {|env| [401, {"Content-Type" => "text/plain"}, ["Fail!"]]}
      end
      run Iceberg::App
    end
  end
    
  config.include(Rack::Test::Methods)
  config.include(Webrat::Matchers)
  config.include(CustomMatchers)
  
  config.include(SinatraMore::AssetTagHelpers)
  config.include(SinatraMore::FormHelpers)
  config.include(SinatraMore::FormatHelpers)
  config.include(SinatraMore::OutputHelpers)
  config.include(SinatraMore::TagHelpers)
  config.include(SinatraMore::RenderHelpers)

  config.include(Iceberg::Helpers::Paths)
  config.include(Iceberg::Helpers::Utilities)
  config.include(Iceberg::Helpers::Visuals)
  
  config.before(:each) do
    DataMapper.setup(:default, 'sqlite3::memory:')
    DataMapper.auto_migrate!
  end
end
