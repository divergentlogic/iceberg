module Iceberg
  module Helpers
    module Paths
      
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
      
      def topics_path(forum)
        "/forums/#{forum.ancestory_path}/topics"
      end
      
      def topic_path(topic)
        "/forums/#{topic.forum.ancestory_path}/topics/#{topic.slug}"
      end
      
      def new_topic_path(forum)
        "/forums/#{forum.ancestory_path}/topics/new"
      end
      
    end
  end
end