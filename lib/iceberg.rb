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

$: << File.expand_path(File.dirname(__FILE__)+'/../will_paginate/lib')
require 'will_paginate'
require 'will_paginate/finders/data_mapper'
require 'will_paginate/view_helpers/base'
require 'will_paginate/view_helpers/link_renderer'

WillPaginate::ViewHelpers::LinkRenderer.class_eval do
  protected
  def url(page)
    url = @template.request.url.split('?').first
    query = @template.request.GET.dup
    page == 1 ? query.reject! {|k,v| k == "page"} : query["page"] = page
    query.empty? ? url : url + "?" + query.map {|k, v| "#{k}=#{v}"}.join("&")
  end
end

require File.expand_path(File.dirname(__FILE__)+'/../sinatra_more/lib/sinatra_more/markup_plugin')
require File.expand_path(File.dirname(__FILE__)+'/../sinatra_more/lib/sinatra_more/render_plugin')
require File.expand_path(File.dirname(__FILE__)+'/helpers/utilities')
require File.expand_path(File.dirname(__FILE__)+'/helpers/visuals')
require File.expand_path(File.dirname(__FILE__)+'/plugins/named_route_plugin')
require File.expand_path(File.dirname(__FILE__)+'/mixins/external_layout')

module Iceberg
  module Models; end
  
  class App < Sinatra::Base
    use Rack::MethodOverride
    use Rack::Flash
    
    include Mixins::ExternalLayout
    
    set :views,     File.dirname(__FILE__) + '/views'
    set :per_page,  25

    register Iceberg::NamedRoutePlugin
    register SinatraMore::MarkupPlugin
    register SinatraMore::RenderPlugin
    
    helpers WillPaginate::ViewHelpers::Base
    helpers Iceberg::Helpers::Utilities
    helpers Iceberg::Helpers::Visuals
    
    before do
      @page     = params['page']      || 1
      @per_page = params['per_page']  || options.per_page
    end
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
    
    class_inheritable_reader :_models
    @_models = {}
    
    def self.models(*models)
      _models
      models.each do |model|
        _models[model.to_sym] = nil
      end
      _models
    end
    
    def self.inherited(base)
      super
      class_defs = models.keys.map do |klass|
        %{class #{klass}
            include Iceberg::Models::#{klass}
          end
          models[:#{klass}] = #{klass}}
      end
      base.class_eval(class_defs.join("\n"))
    end
    
    models :Board, :Topic, :Post
    
    helpers do
      def model_for(model)
        self.class.models[model]
      end
      
      def params_for(model)
        key = model_for(model).to_s.underscore.gsub('/', '-')
        params[key]
      end
    end
    
  end
end
