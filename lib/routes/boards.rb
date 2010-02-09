module Iceberg
  module Routes
    module Boards

      def self.registered(app)
        app.get :boards do
          @boards = ::Iceberg::Board.ordered(:parent_id => nil)
          haml :'boards/index'
        end
        
        app.post :boards do
          @board = ::Iceberg::Board.new(params['iceberg-board'])
          if @board.save
            redirect path_for(:board, @board.parent)
          else
            haml :'boards/new'
          end
        end
        
        app.get :new_board do
          slugs = split_splat
          @parent = ::Iceberg::Board.by_ancestory(slugs)
          if (!slugs.empty? && @parent) || slugs.empty?
            @board = ::Iceberg::Board.new(:parent => @parent)
            haml :'boards/new'
          else
            404
          end
        end
        
        app.get :edit_board do |id|
          @board = ::Iceberg::Board.get(id)
          if @board
            haml :'boards/edit'
          else
            404
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
            404
          end
        end
        
        app.get :board_atom do
          slugs = split_splat
          @board = ::Iceberg::Board.by_ancestory(slugs)
          if @board && @board.allow_topics?
            headers['Content-Type'] = 'application/atom+xml'
            builder :'boards/show', :layout => false
          else
            404
          end
        end
        
        app.get :board do |board|
          slugs = split_splat
          @board = ::Iceberg::Board.by_ancestory(slugs)
          if @board
            haml :'boards/show'
          else
            404
          end
        end
      end
      
    end
  end
end
