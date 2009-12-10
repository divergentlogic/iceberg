module Sinatra
  module Iceberg
    module Forums
      module Helpers

      end

      def self.registered(app)
        app.helpers Helpers
        
        app.map(:forums).to("/forums")
        app.map(:forum).to("/forums/:forum")
        app.map(:new_forum).to("/forums/new")

        app.get :forums do
          @categories = ::Iceberg::Category.ordered
          haml :'forums/index'
        end
        
        app.post :forums do
          @forum = ::Iceberg::Forum.new(params['iceberg-forum'])
          if @forum.save
            redirect url_for(:forums)
          else
            haml :'forums/new'
          end
        end
        
        app.get :new_forum do
          @categories = ::Iceberg::Category.ordered
          @forum = ::Iceberg::Forum.new
          haml :'forums/new'
        end
        
        app.get :forum do |forum|
          @forum = ::Iceberg::Forum.first(:permalink => forum)
          haml :'forums/show'
        end
      end
    end
  end
end
