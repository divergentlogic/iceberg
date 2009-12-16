module Sinatra
  module Iceberg
    module Posts
      module Helpers
        def new_post_path(topic, post=nil)
          if post
            "/forums/#{topic.forum.ancestory_path}/topics/#{topic.slug}/reply/#{post.id}"
          else
            "/forums/#{topic.forum.ancestory_path}/topics/#{topic.slug}/reply"
          end
        end
        
        def posts_path(post)
          new_post_path(post.topic, post)
        end
      end

      def self.registered(app)
        app.helpers Helpers

        ["/forums/*/topics/:topic/reply", "/forums/*/topics/:topic/reply/:post"].each do |path|
          app.get path do
            slugs = split_splat
            @forum = ::Iceberg::Forum.get_child_from_slugs(slugs)
            @topic = @forum.topics.first(:slug => params[:topic])
            @parent = params[:post] ? @topic.posts.first(:id => params[:post]) : @topic.posts.first
            @post = @topic.posts.new(:parent => @parent)
            haml :'posts/new'
          end
        end
        
        app.post "/forums/*/topics/:topic/reply/:post" do
          slugs = split_splat
          @forum = ::Iceberg::Forum.get_child_from_slugs(slugs)
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
