module Iceberg
  module Routes
    module Boards

      def self.registered(app)
        app.get :boards do
          @boards = ::Iceberg::Board.ordered(:parent_id => nil)
          haml :'boards/index'
        end
        
        app.post :create_board do
          @board = ::Iceberg::Board.new(params['iceberg-board'])
          if @board.save
            redirect path_for(:board, @board.parent)
          else
            haml :'boards/new'
          end
        end
        
        app.get :new_board do |id|
          @parent = Iceberg::Board.get(id.to_i)
          halt 404 if id && @parent.nil?
          @board = ::Iceberg::Board.new(:parent => @parent)
          haml :'boards/new'
        end
        
        app.get :edit_board do |id|
          @board = ::Iceberg::Board.get(id)
          halt 404 unless @board
          haml :'boards/edit'
        end
        
        app.put :update_board do |id|
          @board = ::Iceberg::Board.get(id)
          halt 404 unless @board
          if @board.update(params['iceberg-board'])
            redirect path_for(:board, @board)
          else
            haml :'boards/edit'
          end
        end
        
        app.get :board_atom do
          @board = ::Iceberg::Board.by_ancestory(split_splat)
          halt 404 unless @board && @board.allow_topics?
          headers['Content-Type'] = 'application/atom+xml'
          builder :'boards/show', :layout => false
        end
        
        app.get :board do |board|
          @board = ::Iceberg::Board.by_ancestory(split_splat)
          halt 404 unless @board
          haml :'boards/show'
        end
      end
      
    end
  end
end
