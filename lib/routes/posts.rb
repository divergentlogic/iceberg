module Iceberg
  module Routes
    module Posts
      
      def self.registered(app)
        app.get :new_post do |topic_id, post_id|
          @topic  = Iceberg::Topic.get(topic_id.to_i)
          @parent = post_id ? @topic.posts.first(:id => post_id.to_i) : @topic.posts.first
          @post = @topic.posts.new(:parent => @parent)
          if params[:quote] == "true"
            @post.message = quote_post(@parent)
          end
          haml :'posts/new'
        end
        
        app.post :create_post do |id|
          @parent = Iceberg::Post.get(id.to_i)
          @post   = @parent.reply(current_author, params['iceberg-post'])
          if @post.save
            redirect path_for(:topic, @post.topic)
          else
            haml :'posts/new'
          end
        end
      end
      
    end
  end
end
