module Iceberg
  module Routes
    module Posts
      
      def self.registered(app)
        ["/forums/*/topics/:topic/reply", "/forums/*/topics/:topic/reply/:post"].each do |path|
          app.get path do
            authenticate!
            slugs = split_splat
            @forum = ::Iceberg::Forum.by_ancestory(slugs)
            @topic = @forum.topics.first(:slug => params[:topic])
            @parent = params[:post] ? @topic.posts.first(:id => params[:post]) : @topic.posts.first
            @post = @topic.posts.new(:parent => @parent)
            haml :'posts/new'
          end
        end
        
        app.post "/forums/*/topics/:topic/reply/:post" do
          authenticate!
          slugs = split_splat
          @forum = ::Iceberg::Forum.by_ancestory(slugs)
          @topic = @forum.topics.first(:slug => params[:topic])
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
