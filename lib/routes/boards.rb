module Iceberg
  module Routes
    module Forums

      def self.registered(app)
        app.get "/boards" do
          @boards = ::Iceberg::Board.ordered(:parent_id => nil)
          haml :'boards/index'
        end
        
        app.post "/boards" do
          authenticate!
          @board = ::Iceberg::Board.new(params['iceberg-board'])
          if @board.save
            redirect board_path(@board.parent)
          else
            haml :'boards/new'
          end
        end
        
        ["/boards/new", "/boards/*/new"].each do |path|
          app.get path do
            authenticate!
            slugs = split_splat
            @parent = ::Iceberg::Board.by_ancestory(slugs)
            @board = ::Iceberg::Board.new(:parent => @parent)
            haml :'boards/new'
          end
        end
        
        app.get "/boards/*.atom" do
          slugs = split_splat
          @board = ::Iceberg::Board.by_ancestory(slugs)
          if @board && @board.allow_topics?
            headers['Content-Type'] = 'application/atom+xml'
            builder :'boards/show', :layout => false
          else
            404
          end
        end
        
        app.get "/boards/*" do |board|
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
