module Sinatra
  module Iceberg
    module Topics
      module Helpers
        # def current_user
        #   ::Iceberg::User.first
        # end
      end

      def self.registered(app)
        app.helpers Helpers
        
        app.map(:topics).to('/forums/:forum/topics')
        app.map(:new_topic).to('/forums/:forum/topics/new')

        app.get :new_topic do |forum|
          @forum = ::Iceberg::Forum.first(:slug => forum)
          @topic = @forum.topics.new
          haml :'topics/new'
        end
        
        app.post :topics do |forum|
          @forum = ::Iceberg::Forum.first(:slug => forum)
          # @forum.topics.post(current_user, params['iceberg-topic'])
          @topic = @forum.topics.post(nil, params['iceberg-topic'])
          if @topic.save
            redirect url_for(:forum, :forum => @forum.slug)
          else
            haml :'topics/new'
          end
        end
      end
    end
  end
end
