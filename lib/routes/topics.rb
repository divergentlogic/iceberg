module Iceberg
  module Routes
    module Topics
      
      module Helpers
        def get_board
          slugs = split_splat
          @board = ::Iceberg::Board.by_ancestory(slugs)
          halt 404 unless @board
        end
      end
      
      def self.registered(app)
        app.helpers Helpers
        
        app.get "/boards/*/topics/new" do
          authenticate!
          get_board
          @topic = @board.topics.new
          haml :'topics/new'
        end
        
        app.post "/boards/*/topics" do
          authenticate!
          get_board
          # TODO add author
          # @board.topics.post(current_user, params['iceberg-topic'])
          @topic = @board.post_topic(nil, params['iceberg-topic'])
          unless @topic.new?
            redirect board_path(@board)
          else
            haml :'topics/new'
          end
        end
        
        app.get "/boards/*/topics/:topic" do
          get_board
          @topic = @board.topics.first(:slug => params[:topic])
          if @topic
            haml :'topics/show'
          else
            404
          end
        end
        
        app.get %r{/topics/([1-9][0-9]*)/move} do |id|
          @topic = Iceberg::Topic.get(id)
          if @topic
            @boards = Iceberg::Board.all(:id.not => @topic.board.id, :allow_topics => true)
            haml :'topics/move'
          else
            404
          end
        end
        
        app.post %r{/topics/([1-9][0-9]*)/move} do |id|
          @topic = Iceberg::Topic.get(id)
          if @topic
            board = Iceberg::Board.get(params['iceberg-topic']['board_id'])
            if @topic.move_to(board)
              redirect topic_path(@topic)
            else
              haml :'topics/move'
            end
          else
            404
          end
        end
        
      end
      
    end
  end
end
