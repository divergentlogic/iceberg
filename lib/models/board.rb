module Iceberg::Models::Board
  include DataMapper::Types

  def self.included(base)
    base.class_eval do

      include DataMapper::Resource
      extend Iceberg::Filters

      property :id,                   Serial
      property :title,                String,   :length => (1..250)
      property :slug,                 Slug,     :length => (1..250)
      property :description,          String,   :length => (1..500)
      property :parent_id,            Integer
      property :position,             Integer,  :default => 0
      property :topics_count,         Integer,  :default => 0
      property :posts_count,          Integer,  :default => 0
      property :created_at,           DateTime
      property :updated_at,           DateTime
      property :last_updated_at,      DateTime
      property :last_user_id,         Integer
      property :last_user_name,       String
      property :last_user_ip_address, IPAddress
      property :allow_topics,         Boolean,  :default => true
      property :deleted_at,           ParanoidDateTime

      has n, :topics, :order => [:sticky.desc, :created_at.desc]
      has n, :posts, :through => :topics
      belongs_to :last_topic, :model => 'Topic', :required => false
      belongs_to :last_post,  :model => 'Post',  :required => false

      validates_present   :title, :slug, :description
      validates_is_unique :title, :scope => :parent_id, :message => "There's already a board with that title"

      is :list, :scope => [:parent_id]
      is :tree, :order => :position
      alias_method :boards, :children

      before :valid?, :set_slug
      before :update do # TODO: replace with :destroy when upgrading to DM 0.10.3
        if attribute_dirty? :deleted_at
          children.destroy
          topics.destroy
        end
      end

      class << self
        def ordered(options={})
          all(options.merge!({:order => [:position]}))
        end

        def by_ancestory(current_user, slugs)
          while !slugs.empty?
            slug = slugs.shift
            child = if child
              child.children(:slug => slug).filtered(current_user).first
            else
              filtered(current_user).first(:slug => slug, :parent_id => nil)
            end
            return nil unless child
          end
          child
        end
      end

      def post_topic(user, attributes={})
        topic      = topics.new(attributes)
        topic.user = user
        topic.valid_for_adding_to_board?
        topic.save(:adding_to_board)
        topic
      end

      def update_cache
        topic = topics.model.last(:board_id => id, :order => [:last_updated_at])
        post  = posts.model.last(:topic_id => topic.id, :order => [:created_at]) if topic
        self.last_topic_id          = topic ? topic.id             : nil
        self.last_post_id           = post  ? post.id              : nil
        self.last_updated_at        = post  ? post.updated_at      : nil
        self.last_user_id           = post  ? post.user_id         : nil
        self.last_user_name         = post  ? post.user_name       : nil
        self.last_user_ip_address   = post  ? post.user_ip_address : nil
        self.topics_count           = topics.model.count(:board_id => id)
        self.posts_count            = posts.model.count(:topic_id => topics.model.all(:board_id => id).map(&:id))
        allow_topics? && topics.empty? ? save : save! # Don't save up the chain
        # TODO - get a better understanding of how associations are saved in DM - this is ugly
      end

      def ancestory
        unless @ancestory
          @ancestory = [slug]
          current = self
          while current.parent
            @ancestory.unshift(current.parent.slug)
            current = current.parent
          end
        end
        @ancestory
      end

      def ancestory_path
        ancestory.join('/')
      end

    protected

      def set_slug
        if title && slug.nil?
          attribute_set(:slug, title.to_url)
        end
      end

    end
  end
end
