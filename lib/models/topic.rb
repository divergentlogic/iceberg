module Iceberg::Models::Topic
  extend ActiveSupport::Concern

  included do
    include DataMapper::Resource
    include Iceberg::Filters

    property :id,                   DataMapper::Property::Serial
    property :title,                DataMapper::Property::String,   :length => (1..250)
    property :slug,                 DataMapper::Property::Slug,     :length => (1..250)
    property :sticky,               DataMapper::Property::Integer,  :default => 0
    property :locked,               DataMapper::Property::Boolean,  :default => false
    property :posts_count,          DataMapper::Property::Integer,  :default => 0
    property :view_count,           DataMapper::Property::Integer,  :default => 0
    property :user_id,              DataMapper::Property::Integer,  :index => true
    property :user_name,            DataMapper::Property::String
    property :user_ip_address,      DataMapper::Property::IPAddress
    property :created_at,           DataMapper::Property::DateTime
    property :updated_at,           DataMapper::Property::DateTime
    property :last_updated_at,      DataMapper::Property::DateTime
    property :last_user_id,         DataMapper::Property::Integer,  :index => true
    property :last_user_name,       DataMapper::Property::String
    property :last_user_ip_address, DataMapper::Property::IPAddress
    property :deleted_at,           DataMapper::Property::ParanoidDateTime

    attr_accessor :user, :message, :existing_topic

    has n,      :posts, :order => [:created_at]
    has n,      :views, :order => [:created_at.desc], :model => 'TopicView'
    has n,      :moves
    belongs_to  :board
    belongs_to  :last_post, :model => 'Post', :required => false

    validates_presence_of   :message, :if => :new?, :when => [:default, :adding_to_board]
    validates_presence_of   :board, :title, :slug, :when => [:default, :adding_to_board]
    validates_uniqueness_of :title, :slug, :scope => :board_id, :message => "A topic with that title has been posted in this board already; maybe you'd like to post under that topic instead?", :when => [:default, :adding_to_board]
    validates_with_method   :board, :method => :validate_board_allows_topics, :when => [:adding_to_board]
    validates_with_method   :title, :method => :validate_move_does_not_exist, :when => [:default, :adding_to_board]

    before  :valid?,  :set_slug
    after   :valid?,  :set_existing_topic
    before  :create,  :set_user_attributes
    after   :create,  :set_post
    before  :destroy do
      posts.destroy
      views.destroy
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
          self.moves.create(:board_path => old.ancestory_path, :topic_slug => slug)
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
      attribute_set(:slug, title.to_url) if title
    end

    def set_user_attributes
      if user
        self.user_id          = user.id         if user.respond_to?(:id)
        self.user_name        = user.name       if user.respond_to?(:name)
        self.user_ip_address  = user.ip_address if user.respond_to?(:ip_address)
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

    def validate_move_does_not_exist
      move = moves.model.first(:board_path => board.ancestory_path, :topic_slug => slug)
      if move
        [false, "This title has already been taken"]
      else
        true
      end
    end
  end
end
