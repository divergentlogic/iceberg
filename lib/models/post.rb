module Iceberg::Models::Post
  include DataMapper::Types
  
  def self.included(base)
    base.class_eval do
      
      include DataMapper::Resource
      
      property :id,                 Serial
      property :message,            Text
      property :parent_id,          Integer
      property :author_id,          Integer
      property :author_name,        String
      property :author_ip_address,  IPAddress
      property :created_at,         DateTime
      property :updated_at,         DateTime

      attr_accessor :author

      belongs_to :topic
      belongs_to :board

      is :tree, :order => :created_at

      validates_present     :message, :board, :topic
      validates_with_method :topic, :method => :validate_topic_is_unlocked

      before  :create,  :set_author_attributes
      after   :create,  :update_caches

      def reply(author, attributes)
        returning self.class.new(attributes) do |post| # FIXME should be posts.create ?
          post.parent = self
          post.author = author
          post.topic  = topic
          post.board  = board
        end
      end

    protected

      def set_author_attributes
        if author
          self.author_id          = author.id         if author.respond_to?(:id)
          self.author_name        = author.name       if author.respond_to?(:name)
          self.author_ip_address  = author.ip_address if author.respond_to?(:ip_address)
        end
      end

      def update_caches
        topic.update_cache
        board.update_cache
      end

      def validate_topic_is_unlocked
        if topic && !topic.locked?
          true
        else
          [false, "This topic has been locked"]
        end
      end
    
    end
  end
end
