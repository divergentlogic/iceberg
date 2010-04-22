module Iceberg::Models::Topic
  include DataMapper::Types

  def self.included(base)
    base.class_eval do

      include DataMapper::Resource

      property :id,                   Serial
      property :title,                String,   :length => (1..250)
      property :slug,                 Slug,     :length => (1..250)
      property :sticky,               Integer,  :default => 0
      property :locked,               Boolean,  :default => false
      property :posts_count,          Integer,  :default => 0
      property :view_count,           Integer,  :default => 0
      property :created_at,           DateTime
      property :updated_at,           DateTime
      property :last_updated_at,      DateTime
      property :last_user_id,         Integer
      property :last_user_name,       String
      property :last_user_ip_address, DataMapper::Types::IPAddress
      property :deleted_at,           ParanoidDateTime

      attr_accessor :user, :message, :existing_topic

      has n,      :posts, :order => [:created_at]
      has n,      :views, :order => [:created_at.desc], :model => 'TopicView'
      belongs_to  :board
      belongs_to  :last_post, :model => 'Post', :required => false

      validates_present     :message, :if => :new?, :when => [:default, :adding_to_board]
      validates_present     :board, :title, :slug, :when => [:default, :adding_to_board]
      validates_is_unique   :title, :slug, :scope => :board_id, :message => "A topic with that title has been posted in this board already; maybe you'd like to post under that topic instead?", :when => [:default, :adding_to_board]
      validates_with_method :board, :method => :validate_board_allows_topics, :when => [:adding_to_board]

      before  :valid?,  :set_slug
      after   :valid?,  :set_existing_topic
      after   :create,  :set_post
      before  :update do # TODO: replace with :destroy when upgrading to DM 0.10.3
        if attribute_dirty? :deleted_at
          posts.destroy
          views.destroy
        end
      end

      def sticky?
        sticky > 0
      end

      def view!(user=nil)
        user_id         = user && user.respond_to?(:id)         ? user.id         : nil
        user_name       = user && user.respond_to?(:name)       ? user.name       : nil
        user_ip_address = user && user.respond_to?(:ip_address) ? user.ip_address : nil
        views.create(:user_id => user_id, :user_name => user_name, :user_ip_address => user_ip_address)
        adjust!({:view_count => 1}, true)
      end

      def move_to(board)
        unless self.board == board
          old = self.board
          self.board = board
          if valid_for_adding_to_board? && save(:adding_to_board)
            self.board.model.get(board.id).update_cache
            self.board.model.get(old.id).update_cache
            return true
          end
        end
        return false
      end

      def update_cache
        post = posts.model.last(:topic_id => id, :order => [:created_at])
        self.last_post_id         = post ? post.id              : nil
        self.last_updated_at      = post ? post.updated_at      : nil
        self.last_user_id         = post ? post.user_id         : nil
        self.last_user_name       = post ? post.user_name       : nil
        self.last_user_ip_address = post ? post.user_ip_address : nil
        self.posts_count          = posts.model.count(:topic_id => id)
        save!
      end

    protected

      def set_slug
        if title && slug.nil?
          attribute_set(:slug, title.to_url)
        end
      end

      def set_post
        post = posts.new(:user => user, :message => message)
        post.save
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
