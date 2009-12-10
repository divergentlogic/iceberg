require 'sinatra/base'
require File.expand_path(File.dirname(__FILE__) + '/../sinatra_more/lib/sinatra_more/markup_plugin')
require File.expand_path(File.dirname(__FILE__) + '/../sinatra_more/lib/sinatra_more/routing_plugin')

require 'haml'

require 'dm-core'
require 'dm-types'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-is-list'

module Iceberg; end

require File.expand_path(File.dirname(__FILE__)+'/models/category')
require File.expand_path(File.dirname(__FILE__)+'/models/forum')
require File.expand_path(File.dirname(__FILE__)+'/models/topic')
require File.expand_path(File.dirname(__FILE__)+'/models/post')
require File.expand_path(File.dirname(__FILE__)+'/models/user')

require File.expand_path(File.dirname(__FILE__)+'/sinatra/iceberg/forums')
require File.expand_path(File.dirname(__FILE__)+'/mixins/external_layout')

module Iceberg
  class App < Sinatra::Base
    include Mixins::ExternalLayout
    
    set :views, File.dirname(__FILE__) + '/sinatra/iceberg/views'

    register SinatraMore::MarkupPlugin
    register SinatraMore::RoutingPlugin
    register Sinatra::Iceberg::Forums
    register Sinatra::Iceberg::Topics
  end
end
