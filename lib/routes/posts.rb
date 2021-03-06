module Iceberg
  class App < Sinatra::Base
    
    get :new_post do |topic_id, post_id|
      @topic  = model_for(:Topic).get(topic_id.to_i)
      @parent = post_id ? @topic.posts.first(:id => post_id.to_i) : @topic.posts.first
      @post = @topic.posts.new(:parent => @parent)
      if params[:quote] == "true"
        @post.message = quote_post(@parent)
      end
      haml :'posts/new'
    end

    post :create_post do |id|
      @parent = model_for(:Post).get(id.to_i)
      @post   = @parent.reply(current_author, params_for(:Post))
      if @post.save
        redirect path_for(:topic, @post.topic)
      else
        haml :'posts/new'
      end
    end
    
    delete :create_post do |id|
      @post = model_for(:Post).get(id.to_i)
      halt 404 unless @post
      @post.destroy
      redirect path_for(:topic, @post.topic)
    end

  end
end
