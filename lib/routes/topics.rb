module Iceberg
  class App < Sinatra::Base

    helpers do
      def get_board
        slugs   = split_splat
        @board  = model_for(:Board).by_ancestory(slugs)
        halt 404 unless @board
      end
    end

    get :new_topic do |board_id|
      @board = model_for(:Board).get(board_id)
      halt 404 unless @board
      @topic = @board.topics.new
      haml :'topics/new'
    end

    post :create_topic do |board_id|
      @board = model_for(:Board).get!(board_id)
      @topic = @board.post_topic(current_author, params_for(:Topic))
      unless @topic.new?
        redirect path_for(:board, @board)
      else
        haml :'topics/new'
      end
    end

    get :topic_atom do
      get_board
      @topic = @board.topics.first(:slug => params[:topic])
      halt 404 unless @topic
      headers['Content-Type'] = 'application/atom+xml'
      builder :'topics/show', :layout => false
    end

    get :topic do
      get_board
      @topic = @board.topics.first(:slug => params[:topic])
      halt 404 unless @topic
      haml :'topics/show'
    end

    get :edit_topic do |id|
      @topic = model_for(:Topic).get(id)
      halt 404 unless @topic
      haml :'topics/edit'
    end

    put :update_topic do |id|
      @topic = model_for(:Topic).get(id)
      halt 404 unless @topic
      if @topic.update(params_for(:Topic))
        redirect path_for(:topic, @topic)
      else
        haml :'topics/edit'
      end
    end

    delete :update_topic do |id|
      @topic = model_for(:Topic).get(id)
      halt 404 unless @topic
      @topic.destroy
      redirect path_for(:board, @topic.board)
    end

    get :move_topic do |id|
      @topic = model_for(:Topic).get(id)
      halt 404 unless @topic
      @boards = model_for(:Board).all(:id.not => @topic.board.id, :allow_topics => true)
      haml :'topics/move'
    end

    post :move_topic do |id|
      @topic = model_for(:Topic).get(id)
      halt 404 unless @topic
      board = model_for(:Board).get(params_for(:Topic)['board_id'])
      if @topic.move_to(board)
        redirect path_for(:topic, @topic)
      else
        haml :'topics/move'
      end
    end

  end
end
