gem_env = "#{File.dirname(__FILE__)}/../vendor/gems/environment.rb"
if File.exists?(gem_env)
  require gem_env
  Bundler.require_env
end

require 'sinatra/base'
require 'haml'
require 'rack-flash'

require 'dm-core'
require 'dm-types'
require 'dm-aggregates'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-is-list'
require 'dm-is-tree'

require File.expand_path(File.dirname(__FILE__)+'/../sinatra_more/lib/sinatra_more/markup_plugin')
require File.expand_path(File.dirname(__FILE__)+'/../sinatra_more/lib/sinatra_more/render_plugin')
require File.expand_path(File.dirname(__FILE__)+'/helpers/utilities')
require File.expand_path(File.dirname(__FILE__)+'/helpers/visuals')
require File.expand_path(File.dirname(__FILE__)+'/plugins/named_route_plugin')
require File.expand_path(File.dirname(__FILE__)+'/mixins/external_layout')

module Iceberg
  class App < Sinatra::Base
    use Rack::MethodOverride
    use Rack::Flash
    
    include Mixins::ExternalLayout
    
    set :views, File.dirname(__FILE__) + '/views'

    register Iceberg::NamedRoutePlugin
    register SinatraMore::MarkupPlugin
    register SinatraMore::RenderPlugin
    
    helpers Iceberg::Helpers::Utilities
    helpers Iceberg::Helpers::Visuals
  end
end

require File.expand_path(File.dirname(__FILE__)+'/routes')
require File.expand_path(File.dirname(__FILE__)+'/routes/posts')
require File.expand_path(File.dirname(__FILE__)+'/routes/topics')
require File.expand_path(File.dirname(__FILE__)+'/routes/boards')

require File.expand_path(File.dirname(__FILE__)+'/models/board')
require File.expand_path(File.dirname(__FILE__)+'/models/topic')
require File.expand_path(File.dirname(__FILE__)+'/models/post')

module Iceberg
  class App < Sinatra::Base
    
    class Author
      if defined? id
        undef id
      end
      attr_accessor :id, :name, :ip_address
      def initialize(values)
        @id         = values[:id]
        @name       = values[:name]
        @ip_address = values[:ip_address]
      end
    end
    
    helpers do
      def current_author
        Iceberg::App::Author.new(:id => nil, :name => "Anonymous", :ip_address => request.ip)
      end
    end
  end
end
