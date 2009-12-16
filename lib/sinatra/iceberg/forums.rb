module Sinatra
  module Iceberg
    module Forums
      module Helpers
        def forums_path
          "/forums"
        end

        def forum_path(forum=nil)
          if forum
            "/forums/#{forum.ancestory_path}"
          else
            forums_path
          end
        end

        def new_forum_path(forum=nil)
          if forum
            "/forums/#{forum.ancestory_path}/new"
          else
            "/forums/new"
          end
        end
      end

      def self.registered(app)
        app.helpers Helpers

        app.get "/forums" do
          @forums = ::Iceberg::Forum.ordered(:parent_id => nil)
          haml :'forums/index'
        end
        
        app.post "/forums" do
          @forum = ::Iceberg::Forum.new(params['iceberg-forum'])
          if @forum.save
            redirect forum_path(@forum.parent)
          else
            haml :'forums/new'
          end
        end
        
        ["/forums/new", "/forums/*/new"].each do |new_forum|
          app.get new_forum do
            slugs = split_splat
            @parent = ::Iceberg::Forum.by_ancestory(slugs)
            @forum = ::Iceberg::Forum.new(:parent => @parent)
            haml :'forums/new'
          end
        end
        
        app.get "/forums/*" do |forum|
          slugs = split_splat
          @forum = ::Iceberg::Forum.by_ancestory(slugs)
          if @forum
            haml :'forums/show'
          else
            404
          end
        end
      end
    end
  end
end
