module Iceberg
  class App < Sinatra::Base

    get :new_post do |topic_id, post_id|
      @topic  = model_for(:Topic).filtered(current_user).first(:id => topic_id.to_i)
      halt 404 unless @topic
      @parent = post_id ? @topic.posts.filtered(current_user).first(:id => post_id.to_i) : @topic.posts.filtered(current_user).first
      @post = @topic.posts.new(:parent => @parent)
      if params[:quote] == "true"
        @post.message = quote_post(@parent)
      end
      haml :'posts/new'
    end

    post :create_post do |id|
      @parent = model_for(:Post).filtered(current_user).first(:id => id.to_i)
      halt 404 unless @parent
      @topic  = @parent.topic
      @post   = @parent.reply(current_user, params_for(:Post))
      unless @post.new?
        redirect path_for(:topic, @topic)
      else
        haml :'posts/new'
      end
    end

    get :edit_post do |id|
      @post = model_for(:Post).filtered(current_user).first(:id => id.to_i)
      halt 404 unless @post
      @topic = @post.topic
      haml :'posts/edit'
    end

    put :create_post do |id|
      @post = model_for(:Post).filtered(current_user).first(:id => id.to_i)
      halt 404 unless @post
      @topic = @post.topic
      @post.attributes = params_for(:Post)
      if @post.save
        redirect path_for(:topic, @topic)
      else
        haml :'posts/edit'
      end
    end

    delete :create_post do |id|
      @post = model_for(:Post).filtered(current_user).first(:id => id.to_i)
      halt 404 unless @post
      @post.destroy
      if @post.topic.deleted_at
        redirect path_for(:board, @post.topic.board)
      else
        redirect path_for(:topic, @post.topic)
      end
    end

  end
end
