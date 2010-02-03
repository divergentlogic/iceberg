require 'sinatra/base'
require File.expand_path(File.dirname(__FILE__) + '/../sinatra_more/lib/sinatra_more/markup_plugin')
require File.expand_path(File.dirname(__FILE__) + '/../sinatra_more/lib/sinatra_more/render_plugin')

require 'haml'

require 'rack-flash'

require 'dm-core'
require 'dm-types'
require 'dm-aggregates'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-is-list'
require 'dm-is-tree'

module Iceberg; end

require File.expand_path(File.dirname(__FILE__)+'/helpers/authentication')
require File.expand_path(File.dirname(__FILE__)+'/helpers/utilities')
require File.expand_path(File.dirname(__FILE__)+'/helpers/visuals')

require File.expand_path(File.dirname(__FILE__)+'/routes')
require File.expand_path(File.dirname(__FILE__)+'/routes/boards')
require File.expand_path(File.dirname(__FILE__)+'/routes/topics')
require File.expand_path(File.dirname(__FILE__)+'/routes/posts')

require File.expand_path(File.dirname(__FILE__)+'/models/board')
require File.expand_path(File.dirname(__FILE__)+'/models/topic')
require File.expand_path(File.dirname(__FILE__)+'/models/post')

require File.expand_path(File.dirname(__FILE__)+'/plugins/named_route_plugin')

require File.expand_path(File.dirname(__FILE__)+'/mixins/external_layout')

module Iceberg
  class App < Sinatra::Base
    use Rack::Flash
    
    include Mixins::ExternalLayout
    
    set :views, File.dirname(__FILE__) + '/views'

    register Iceberg::NamedRoutePlugin
    register SinatraMore::MarkupPlugin
    register SinatraMore::RenderPlugin
    
    helpers Iceberg::Helpers::Authentication
    helpers Iceberg::Helpers::Utilities
    helpers Iceberg::Helpers::Visuals
    
    register Iceberg::Routes
    register Iceberg::Routes::Posts
    register Iceberg::Routes::Topics
    register Iceberg::Routes::Boards
  end
end
