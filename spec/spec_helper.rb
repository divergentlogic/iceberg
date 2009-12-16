ENV['RACK_ENV'] ||= 'test'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'iceberg'
require 'sinatra'
require 'spec'
require 'spec/autorun'
require 'spec/interop/test'
require 'rack/test'
require 'factory_girl'

Dir[File.expand_path(File.join(File.dirname(__FILE__), 'support', '**', '*.rb'))].each {|f| require f}

Iceberg::App.set :environment, :test
Iceberg::App.set :run, false
Iceberg::App.set :raise_errors, true
Iceberg::App.set :logging, false

Spec::Runner.configure do |config|
  def app
    Iceberg::App
  end
    
  config.include(Rack::Test::Methods)
  config.include(CustomMatchers)
  
  config.include(SinatraMore::AssetTagHelpers)
  config.include(SinatraMore::FormHelpers)
  config.include(SinatraMore::FormatHelpers)
  config.include(SinatraMore::OutputHelpers)
  config.include(SinatraMore::TagHelpers)
  config.include(SinatraMore::RoutingHelpers)
  config.include(Sinatra::Iceberg::Helpers)
  config.include(Sinatra::Iceberg::Forums::Helpers)
  config.include(Sinatra::Iceberg::Topics::Helpers)
  config.include(Sinatra::Iceberg::Posts::Helpers)
  
  config.before(:each) do
    DataMapper.setup(:default, 'sqlite3::memory:')
    DataMapper.auto_migrate!
  end
end
