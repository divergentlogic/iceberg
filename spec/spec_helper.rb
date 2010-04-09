begin
  # Require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

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

Spec::Runner.configure do |config|
  def app
    @app ||= Rack::Builder.app do
      use Rack::Session::Cookie
      run TestApp
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
