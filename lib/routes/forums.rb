module Iceberg
  module Routes
    module Forums

      def self.registered(app)
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
