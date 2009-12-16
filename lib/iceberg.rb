require 'sinatra/base'
require File.expand_path(File.dirname(__FILE__) + '/../sinatra_more/lib/sinatra_more/markup_plugin')
require File.expand_path(File.dirname(__FILE__) + '/../sinatra_more/lib/sinatra_more/routing_plugin')

require 'haml'

require 'dm-core'
require 'dm-types'
require 'dm-aggregates'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-is-list'
require 'dm-is-tree'

module Iceberg; end

require File.expand_path(File.dirname(__FILE__)+'/sinatra/iceberg/helpers')
require File.expand_path(File.dirname(__FILE__)+'/sinatra/iceberg/forums')
require File.expand_path(File.dirname(__FILE__)+'/sinatra/iceberg/topics')
require File.expand_path(File.dirname(__FILE__)+'/sinatra/iceberg/posts')

require File.expand_path(File.dirname(__FILE__)+'/models/forum')
require File.expand_path(File.dirname(__FILE__)+'/models/topic')
require File.expand_path(File.dirname(__FILE__)+'/models/post')

require File.expand_path(File.dirname(__FILE__)+'/sinatra/iceberg/forums')
require File.expand_path(File.dirname(__FILE__)+'/mixins/external_layout')

module Iceberg
  class App < Sinatra::Base
    include Mixins::ExternalLayout
    
    helpers Sinatra::Iceberg::Helpers
    
    set :views, File.dirname(__FILE__) + '/sinatra/iceberg/views'

    register SinatraMore::MarkupPlugin
    register Sinatra::Iceberg::Posts
    register Sinatra::Iceberg::Topics
    register Sinatra::Iceberg::Forums
  end
end
