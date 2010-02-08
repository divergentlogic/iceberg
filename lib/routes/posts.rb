module Iceberg
  module Routes
    module Posts
      
      def self.registered(app)
        app.get :new_post do
          slugs = split_splat
          @board = ::Iceberg::Board.by_ancestory(slugs)
          @topic = @board.topics.first(:slug => params[:topic])
          @parent = params[:post] ? @topic.posts.first(:id => params[:post]) : @topic.posts.first
          @post = @topic.posts.new(:parent => @parent)
          if params[:quote] == "true"
            @post.message = quote_post(@parent)
          end
          haml :'posts/new'
        end
        
        app.post :posts do
          slugs = split_splat
          @board = ::Iceberg::Board.by_ancestory(slugs)
          @topic = @board.topics.first(:slug => params[:topic])
          @parent = @topic.posts.first(:id => params[:post])
          @post = @parent.reply(current_author, params['iceberg-post'])
          if @post.save
            redirect path_for(:topic, @topic)
          else
            haml :'posts/new'
          end
        end
      end
      
    end
  end
end
