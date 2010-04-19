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
      property :deleted_at,         ParanoidDateTime

      attr_accessor :author

      belongs_to :topic

      is :tree, :order => :created_at
      alias_method :replies, :children

      validates_present     :message, :topic
      validates_with_method :topic, :method => :validate_topic_is_unlocked, :if => :new?

      before  :create,  :set_author_attributes
      after   :create,  :update_caches
      before  :update do # TODO: replace with :destroy when upgrading to DM 0.10.3
        if attribute_dirty?(:deleted_at) && !topic.attribute_dirty?(:deleted_at)
          children.each do |child|
            child.parent = parent
            child.save!
          end
        end
      end

      def reply(author, attributes)
        reply        = children.new(attributes)
        reply.author = author
        reply.topic  = topic
        reply.save
        reply
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
        update_topic = self.topic.model.get(topic_id)
        update_board = topic.board.model.get(topic.board_id)
        update_topic.update_cache
        update_board.update_cache
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
