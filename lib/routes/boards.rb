module Iceberg
  class App < Sinatra::Base

    get :boards do
      @boards = model_for(:Board).ordered(:parent_id => nil)
      haml :'boards/index'
    end
    
    post :create_board do
      @board = model_for(:Board).new(params_for(:Board))
      if @board.save
        redirect path_for(:board, @board.parent)
      else
        haml :'boards/new'
      end
    end
    
    get :new_board do |id|
      @parent = model_for(:Board).get(id.to_i)
      halt 404 if id && @parent.nil?
      @board = model_for(:Board).new(:parent => @parent)
      haml :'boards/new'
    end
    
    get :edit_board do |id|
      @board = model_for(:Board).get(id)
      halt 404 unless @board
      haml :'boards/edit'
    end
    
    put :update_board do |id|
      @board = model_for(:Board).get(id)
      halt 404 unless @board
      if @board.update(params_for(:Board))
        redirect path_for(:board, @board)
      else
        haml :'boards/edit'
      end
    end
    
    get :board_atom do
      @board = model_for(:Board).by_ancestory(split_splat)
      halt 404 unless @board && @board.allow_topics?
      headers['Content-Type'] = 'application/atom+xml'
      builder :'boards/show', :layout => false
    end
    
    get :board do
      @board = model_for(:Board).by_ancestory(split_splat)
      halt 404 unless @board
      haml :'boards/show'
    end
      
  end
end
