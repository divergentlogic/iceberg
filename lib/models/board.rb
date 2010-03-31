module Iceberg::Models::Board
  include DataMapper::Types

  def self.included(base)
    base.class_eval do

      include DataMapper::Resource

      property :id,                     Serial
      property :title,                  String,   :length => (1..250)
      property :slug,                   Slug,     :length => (1..250)
      property :description,            String,   :length => (1..500)
      property :parent_id,              Integer
      property :position,               Integer,  :default => 0
      property :topics_count,           Integer,  :default => 0
      property :posts_count,            Integer,  :default => 0
      property :created_at,             DateTime
      property :updated_at,             DateTime
      property :last_updated_at,        DateTime
      property :last_author_id,         Integer
      property :last_author_name,       String
      property :last_author_ip_address, IPAddress
      property :allow_topics,           Boolean,  :default => true
      property :deleted_at,             ParanoidDateTime

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

      class << self
        def ordered(options={})
          all(options.merge!({:order => [:position]}))
        end

        def by_ancestory(slugs)
          while !slugs.empty?
            slug = slugs.shift
            child = if child
              child.children(:slug => slug).first
            else
              first(:slug => slug, :parent_id => nil)
            end
            return nil unless child
          end
          child
        end
      end

      def post_topic(author, attributes={})
        topic = topics.model.new(attributes)
        topic.board   = self
        topic.author  = author
        topic.valid_for_adding_to_board? # errors aren't getting added without explicity calling the validation function
        topic.save(:adding_to_board)
        topic
      end

      def update_cache
        topics.reload
        last_post   = posts.first(:order => [:updated_at.desc])
        last_topic  = topics.first(:order => [:last_updated_at.desc])

        self.last_topic_id          = last_topic ? last_topic.id : nil
        self.last_post_id           = last_post ? last_post.id : nil
        self.last_updated_at        = last_post ? last_post.updated_at : nil
        self.last_author_id         = last_post ? last_post.author_id : nil
        self.last_author_name       = last_post ? last_post.author_name : nil
        self.last_author_ip_address = last_post ? last_post.author_ip_address : nil
        self.topics_count           = topics.count
        self.posts_count            = posts.count

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
