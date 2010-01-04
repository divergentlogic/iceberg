module Iceberg
  module Routes
    module Topics
      
      module Helpers
        def get_forum
          slugs = split_splat
          @forum = ::Iceberg::Forum.by_ancestory(slugs)
          halt 404 unless @forum
        end
      end
      
      def self.registered(app)
        app.helpers Helpers
        
        app.get "/forums/*/topics/new" do
          get_forum
          @topic = @forum.topics.new
          haml :'topics/new'
        end
        
        app.post "/forums/*/topics" do
          get_forum
          # TODO add author
          # @forum.topics.post(current_user, params['iceberg-topic'])
          @topic = @forum.post_topic(nil, params['iceberg-topic'])
          unless @topic.new?
            redirect forum_path(@forum)
          else
            haml :'topics/new'
          end
        end
        
        app.get "/forums/*/topics/:topic" do
          get_forum
          @topic = @forum.topics.first(:slug => params[:topic])
          if @topic
            haml :'topics/show'
          else
            404
          end
        end
      end
      
    end
  end
end
