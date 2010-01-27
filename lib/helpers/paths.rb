module Iceberg
  module Helpers
    module Paths
      
      def boards_path
        "/boards"
      end

      def board_path(board=nil)
        if board
          "/boards/#{board.ancestory_path}"
        else
          boards_path
        end
      end

      def new_board_path(board=nil)
        if board
          "/boards/#{board.ancestory_path}/new"
        else
          "/boards/new"
        end
      end
      
      def new_post_path(topic, post=nil, quote=false)
        quote_query = "?quote=true" if quote
        if post
          "/boards/#{topic.board.ancestory_path}/topics/#{topic.slug}/reply/#{post.id}#{quote_query}"
        else
          "/boards/#{topic.board.ancestory_path}/topics/#{topic.slug}/reply#{quote_query}"
        end
      end
      
      def new_quoted_post_path(topic, post=nil)
        new_post_path(topic, post, true)
      end
      
      def posts_path(post)
        new_post_path(post.topic, post)
      end
      
      def topics_path(board)
        "/boards/#{board.ancestory_path}/topics"
      end
      
      def topic_path(topic)
        "/boards/#{topic.board.ancestory_path}/topics/#{topic.slug}"
      end
      
      def new_topic_path(board)
        "/boards/#{board.ancestory_path}/topics/new"
      end
      
    end
  end
end