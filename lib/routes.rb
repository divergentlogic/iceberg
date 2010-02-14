module Iceberg
  module Routes
    
    def self.registered(app)
      app.register_route(:boards) do
        path      "/boards/?"
        generate  "/boards"
      end
      
      app.register_route(:new_board) do
        path %r{/boards/([1-9][0-9]*/)?new/?}
        generate do |board|
          board ? "/boards/#{board.id}/new" : "/boards/new"
        end
      end
      
      app.register_route(:create_board) do
        path      "/boards/?"
        generate  "/boards"
      end
      
      app.register_route(:edit_board) do
        path %r{/boards/([1-9][0-9]*)/edit/?}
        generate do |board|
          "/boards/#{board.id}/edit"
        end
      end
      
      app.register_route(:update_board) do
        path %r{/boards/([1-9][0-9]*)/?}
        generate do |board|
          "/boards/#{board.id}"
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
        path %r{/boards/([1-9][0-9]*)/topics/new/?}
        generate do |board|
          "/boards/#{board.id}/topics/new"
        end
      end
      
      app.register_route(:create_topic) do
        path  %r{/boards/([1-9][0-9]*)/topics/?}
        generate do |board|
          "/boards/#{board.id}/topics"
        end
      end
      
      app.register_route(:edit_topic) do
        path %r{/topics/([1-9][0-9]*)/edit/?}
        generate do |topic|
          "/topics/#{topic.id}/edit"
        end
      end
      
      app.register_route(:update_topic) do
        path %r{/topics/([1-9][0-9]*)/?}
        generate do |topic|
          "/topics/#{topic.id}"
        end
      end
      
      app.register_route(:move_topic) do
        path %r{/topics/([1-9][0-9]*)/move/?}
        generate do |topic|
          "/topics/#{topic.id}/move"
        end
      end
      
      app.register_route(:new_post) do
        path %r{/topics/([1-9][0-9]*)/posts/([1-9][0-9]*/)?reply/?}
        generate do |topic, post|
          if post
            "/topics/#{topic.id}/posts/#{post.id}/reply"
          else
            "/topics/#{topic.id}/posts/reply"
          end
        end
      end

      app.register_route(:create_post) do
        path %r{/posts/([1-9][0-9]*)/?}
        generate do |post|
          "/posts/#{post.id}"
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
