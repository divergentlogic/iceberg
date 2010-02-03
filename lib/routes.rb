module Iceberg
  module Routes
    
    def self.registered(app)
      app.register_route(:boards) do
        path      "/boards/?"
        generate  "/boards"
      end
      
      app.register_route(:new_board) do
        path ["/boards/new/?", "/boards/*/new/?"]
        generate do |board|
          board ? "/boards/#{board.ancestory_path}/new" : "/boards/new"
        end
      end
      
      app.register_route(:board) do
        path "/boards/*"
        generate do |board|
          board ? "/boards/#{board.ancestory_path}" : "/boards"
        end
      end
      
      app.register_route(:board_atom) do
        path "/boards/*.atom"
        generate do |board|
          board ? "/boards/#{board.ancestory_path}.atom" : "/boards.atom"
        end
      end
      
      app.register_route(:topics) do
        path "/boards/*/topics/?"
        generate do |board|
          "/boards/#{board.ancestory_path}/topics"
        end
      end
      
      app.register_route(:topic) do
        path "/boards/*/topics/:topic/?"
        generate do |topic|
          "/boards/#{topic.board.ancestory_path}/topics/#{topic.slug}"
        end
      end
      
      app.register_route(:topic_atom) do
        path "/boards/*/topics/:topic.atom"
        generate do |topic|
          "/boards/#{topic.board.ancestory_path}/topics/#{topic.slug}.atom"
        end
      end
      
      app.register_route(:new_topic) do
        path "/boards/*/topics/new/?"
        generate do |board|
          "/boards/#{board.ancestory_path}/topics/new"
        end
      end
      
      app.register_route(:move_topic) do
        path %r{/topics/([1-9][0-9]*)/move/?}
        generate do |topic|
          "/topics/#{topic.id}/move"
        end
      end
      
      app.register_route(:new_post) do
        path ["/boards/*/topics/:topic/reply/?", "/boards/*/topics/:topic/reply/:post/?"]
        generate do |topic, post|
          if post
            "/boards/#{topic.board.ancestory_path}/topics/#{topic.slug}/reply/#{post.id}"
          else
            "/boards/#{topic.board.ancestory_path}/topics/#{topic.slug}/reply"
          end
        end
      end

      app.register_route(:posts) do
        path "/boards/*/topics/:topic/reply/:post"
        generate do |post|
          "/boards/#{post.topic.board.ancestory_path}/topics/#{post.topic.slug}/reply/#{post.id}"
        end
      end

      app.register_route(:post) do
        path "/boards/*/topic/:topic#:post_id"
        generate do |post|
          "/boards/#{post.topic.board.ancestory_path}/topics/#{post.topic.slug}##{post.id}"
        end
      end
    end
    
  end
end
