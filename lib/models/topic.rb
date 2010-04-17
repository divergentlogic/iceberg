module Iceberg::Models::Topic
  include DataMapper::Types

  def self.included(base)
    base.class_eval do

      include DataMapper::Resource

      property :id,                     Serial
      property :title,                  String,   :length => (1..250)
      property :slug,                   Slug,     :length => (1..250)
      property :sticky,                 Integer,  :default => 0
      property :locked,                 Boolean,  :default => false
      property :posts_count,            Integer,  :default => 0
      property :view_count,             Integer,  :default => 0
      property :created_at,             DateTime
      property :updated_at,             DateTime
      property :last_updated_at,        DateTime
      property :last_author_id,         Integer
      property :last_author_name,       String
      property :last_author_ip_address, DataMapper::Types::IPAddress
      property :deleted_at,             ParanoidDateTime

      attr_accessor :author, :message, :existing_topic

      has n,      :posts, :order => [:created_at]
      has n,      :views, :order => [:created_at.desc], :model => 'TopicView'
      belongs_to  :board
      belongs_to  :last_post, :model => 'Post', :required => false

      validates_present     :message, :on => [:create]
      validates_present     :board, :title, :slug, :when => [:default, :adding_to_board, :create]
      validates_is_unique   :title, :slug, :scope => :board_id, :message => "A topic with that title has been posted in this board already; maybe you'd like to post under that topic instead?", :when => [:default, :adding_to_board, :create]
      validates_with_method :board, :method => :validate_board_allows_topics, :when => [:adding_to_board, :create]

      before  :valid?,  :set_slug
      after   :valid?,  :set_existing_topic
      after   :create,  :set_post

      def sticky?
        sticky > 0
      end

      def view!(viewer=nil)
        viewer_id         = viewer && viewer.respond_to?(:id)         ? viewer.id         : nil
        viewer_name       = viewer && viewer.respond_to?(:name)       ? viewer.name       : nil
        viewer_ip_address = viewer && viewer.respond_to?(:ip_address) ? viewer.ip_address : nil
        views.create(:viewer_id => viewer_id, :viewer_name => viewer_name, :viewer_ip_address => viewer_ip_address)
        adjust!({:view_count => 1}, true)
      end

      def move_to(board)
        unless self.board == board
          old = self.board
          self.board = board
          if valid_for_adding_to_board? && save(:adding_to_board)
            board.update_cache
            old.update_cache
            return true
          end
        end
        return false
      end

      def update_cache
        last_post = posts.first(:order => [:updated_at.desc])

        self.last_post_id           = last_post ? last_post.id : nil
        self.last_updated_at        = last_post ? last_post.updated_at : nil
        self.last_author_id         = last_post ? last_post.author_id : nil
        self.last_author_name       = last_post ? last_post.author_name : nil
        self.last_author_ip_address = last_post ? last_post.author_ip_address : nil
        self.posts_count            = posts.count
        save! # Don't save up the chain
      end

    protected

      def set_slug
        if title && slug.nil?
          attribute_set(:slug, title.to_url)
        end
      end

      def set_post
        posts.create({
          :author => author,
          :message => message
        })
      end

      def set_existing_topic
        if errors.on(:title) || errors.on(:slug)
          self.existing_topic = self.class.first(:title => title) || self.class.first(:slug => slug)
        end
      end

      def validate_board_allows_topics
        if board && board.allow_topics?
          true
        else
          [false, "This board does not allow topics"]
        end
      end

    end
  end
end
