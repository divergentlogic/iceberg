module Iceberg
  class App < Sinatra::Base

    get :boards do
      @boards = Board.ordered(:parent_id => nil)
      haml :'boards/index'
    end
    
    post :create_board do
      @board = Board.new(params['iceberg-app-board'])
      if @board.save
        redirect path_for(:board, @board.parent)
      else
        haml :'boards/new'
      end
    end
    
    get :new_board do |id|
      @parent = Board.get(id.to_i)
      halt 404 if id && @parent.nil?
      @board = Board.new(:parent => @parent)
      haml :'boards/new'
    end
    
    get :edit_board do |id|
      @board = Board.get(id)
      halt 404 unless @board
      haml :'boards/edit'
    end
    
    put :update_board do |id|
      @board = Board.get(id)
      halt 404 unless @board
      if @board.update(params['iceberg-app-board'])
        redirect path_for(:board, @board)
      else
        haml :'boards/edit'
      end
    end
    
    get :board_atom do
      @board = Board.by_ancestory(split_splat)
      halt 404 unless @board && @board.allow_topics?
      headers['Content-Type'] = 'application/atom+xml'
      builder :'boards/show', :layout => false
    end
    
    get :board do |board|
      @board = Board.by_ancestory(split_splat)
      halt 404 unless @board
      haml :'boards/show'
    end
      
  end
end
