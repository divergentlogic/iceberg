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
          if @board
            haml :'boards/edit'
          else
            halt 404
          end
        end
        
        app.put :update_board do |id|
          @board = ::Iceberg::Board.get(id)
          if @board
            if @board.update(params['iceberg-board'])
              redirect path_for(:board, @board)
            else
              haml :'boards/edit'
            end
          else
            halt 404
          end
        end
        
        app.get :board_atom do
          slugs = split_splat
          @board = ::Iceberg::Board.by_ancestory(slugs)
          if @board && @board.allow_topics?
            headers['Content-Type'] = 'application/atom+xml'
            builder :'boards/show', :layout => false
          else
            halt 404
          end
        end
        
        app.get :board do |board|
          slugs = split_splat
          @board = ::Iceberg::Board.by_ancestory(slugs)
          if @board
            haml :'boards/show'
          else
            halt 404
          end
        end
      end
      
    end
  end
end
