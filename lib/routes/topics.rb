module Iceberg
  class App < Sinatra::Base

    helpers do
      def get_topic(forum_path=:topic)
        slugs  = split_splat
        @board = model_for(:Board).by_ancestory(current_user, slugs)
        @topic = @board.topics.filtered(current_user).first(:slug => params[:topic]) if @board
        unless @topic
          move = model_for(:Move).first(:board_path => slugs.join('/'), :topic_slug => params[:topic])
          if move
            redirect path_for(forum_path, move.topic), 301
          else
            halt 404
          end
        end
      end
    end

    get :new_topic do |board_id|
      @board = model_for(:Board).filtered(current_user).first(:id => board_id)
      halt 404 unless @board
      @topic = @board.topics.new
      haml :'topics/new'
    end

    post :create_topic do |board_id|
      @board = model_for(:Board).filtered(current_user).first(:id => board_id)
      halt 404 unless @board
      @topic = @board.post_topic(current_user, params_for(:Topic))
      unless @topic.new?
        redirect path_for(:topic, @topic)
      else
        haml :'topics/new'
      end
    end

    get :topic_atom do
      get_topic(:topic_atom)
      headers['Content-Type'] = 'application/atom+xml'
      builder :'topics/show', :layout => false
    end

    get :topic do
      get_topic
      @topic.view!(current_user)
      haml :'topics/show'
    end

    get :edit_topic do |id|
      @topic = model_for(:Topic).filtered(current_user).first(:id => id)
      halt 404 unless @topic
      haml :'topics/edit'
    end

    put :update_topic do |id|
      @topic = model_for(:Topic).filtered(current_user).first(:id => id)
      halt 404 unless @topic
      if @topic.update(params_for(:Topic))
        redirect path_for(:topic, @topic)
      else
        haml :'topics/edit'
      end
    end

    delete :update_topic do |id|
      @topic = model_for(:Topic).filtered(current_user).first(:id => id)
      halt 404 unless @topic
      @topic.destroy
      redirect path_for(:board, @topic.board)
    end

    get :move_topic do |id|
      @topic = model_for(:Topic).filtered(current_user).first(:id => id)
      halt 404 unless @topic
      @boards = model_for(:Board).filtered(current_user, :id.not => @topic.board.id, :allow_topics => true)
      haml :'topics/move'
    end

    post :move_topic do |id|
      @topic = model_for(:Topic).filtered(current_user).first(:id => id)
      halt 404 unless @topic
      board = model_for(:Board).filtered(current_user).first(:id => params_for(:Topic)['board_id'])
      if @topic.move_to(board)
        redirect path_for(:topic, @topic)
      else
        haml :'topics/move'
      end
    end

  end
end
