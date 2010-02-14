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
        
        app.get :new_topic do |board_id|
          @board = Iceberg::Board.get(board_id)
          halt 404 unless @board
          @topic = @board.topics.new
          haml :'topics/new'
        end
        
        app.post :create_topic do |board_id|
          @board = Iceberg::Board.get!(board_id)
          @topic = @board.post_topic(current_author, params['iceberg-topic'])
          unless @topic.new?
            redirect path_for(:board, @board)
          else
            haml :'topics/new'
          end
        end

        app.get :topic_atom do
          get_board
          @topic = @board.topics.first(:slug => params[:topic])
          halt 404 unless @topic
          headers['Content-Type'] = 'application/atom+xml'
          builder :'topics/show', :layout => false
        end
        
        app.get :topic do
          get_board
          @topic = @board.topics.first(:slug => params[:topic])
          halt 404 unless @topic
          haml :'topics/show'
        end
        
        app.get :edit_topic do |id|
          @topic = Iceberg::Topic.get(id)
          halt 404 unless @topic
          haml :'topics/edit'
        end
        
        app.put :update_topic do |id|
          @topic = Iceberg::Topic.get(id)
          halt 404 unless @topic
          if @topic.update(params['iceberg-topic'])
            redirect path_for(:topic, @topic)
          else
            haml :'topics/edit'
          end
        end
        
        app.get :move_topic do |id|
          @topic = Iceberg::Topic.get(id)
          halt 404 unless @topic
          @boards = Iceberg::Board.all(:id.not => @topic.board.id, :allow_topics => true)
          haml :'topics/move'
        end
        
        app.post :move_topic do |id|
          @topic = Iceberg::Topic.get(id)
          halt 404 unless @topic
          board = Iceberg::Board.get(params['iceberg-topic']['board_id'])
          if @topic.move_to(board)
            redirect path_for(:topic, @topic)
          else
            haml :'topics/move'
          end
        end
        
      end
      
    end
  end
end
