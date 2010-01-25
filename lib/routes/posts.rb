module Iceberg
  module Routes
    module Posts
      
      def self.registered(app)
        ["/boards/*/topics/:topic/reply", "/boards/*/topics/:topic/reply/:post"].each do |path|
          app.get path do
            authenticate!
            slugs = split_splat
            @board = ::Iceberg::Board.by_ancestory(slugs)
            @topic = @board.topics.first(:slug => params[:topic])
            @parent = params[:post] ? @topic.posts.first(:id => params[:post]) : @topic.posts.first
            @post = @topic.posts.new(:parent => @parent)
            haml :'posts/new'
          end
        end
        
        app.post "/boards/*/topics/:topic/reply/:post" do
          authenticate!
          slugs = split_splat
          @board = ::Iceberg::Board.by_ancestory(slugs)
          @topic = @board.topics.first(:slug => params[:topic])
          @parent = @topic.posts.first(:id => params[:post])
          @post = @parent.reply(nil, params['iceberg-post']) # TODO: add author
          if @post.save
            redirect topic_path(@topic)
          else
            haml :'posts/new'
          end
        end
      end
      
    end
  end
end
