require 'sinatra/base'
require 'haml'
require 'rack-flash'
require 'active_support'

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
  module Models; end

  class App < Sinatra::Base
    use Rack::MethodOverride
    use Rack::Flash

    include Mixins::ExternalLayout

    set :views,     File.dirname(__FILE__) + '/views'

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

Dir[File.join(File.dirname(__FILE__), 'models', '**')].each {|f| require f}

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

    models :Board, :Topic, :Post, :TopicView

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
