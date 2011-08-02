module Iceberg::Models::Post
  extend ActiveSupport::Concern
  include DataMapper::Types

  included do
    include DataMapper::Resource
    include Iceberg::Filters

    property :id,               Serial
    property :message,          Text
    property :parent_id,        Integer
    property :user_id,          Integer
    property :user_name,        String
    property :user_ip_address,  IPAddress
    property :created_at,       DateTime
    property :updated_at,       DateTime
    property :deleted_at,       ParanoidDateTime

    attr_accessor :user

    belongs_to :topic

    is :tree, :order => :created_at
    alias_method :replies, :children

    validates_present     :message, :topic
    validates_with_method :topic, :method => :validate_topic_is_unlocked, :if => :new?

    before  :create,  :set_user_attributes
    after   :create,  :update_caches
    before  :update do # TODO: replace with :destroy when upgrading to DM 0.10.3
      if attribute_dirty?(:deleted_at) && !topic.attribute_dirty?(:deleted_at)
        children.each do |child|
          child.parent = parent
          child.save!
        end
      end
    end
    after :update do # TODO: replace with :destroy when upgrading to DM 0.10.3
      if deleted_at
        update_topic = self.topic.model.get(topic_id)
        if update_topic
          if update_topic.posts.count > 0
            update_topic.update_cache
          else
            update_topic.destroy
          end
        end
      end
    end

    def reply(user, attributes)
      reply        = children.new(attributes)
      reply.user = user
      reply.topic  = topic
      reply.save
      reply
    end

  protected

    def set_user_attributes
      if user
        self.user_id          = user.id         if user.respond_to?(:id)
        self.user_name        = user.name       if user.respond_to?(:name)
        self.user_ip_address  = user.ip_address if user.respond_to?(:ip_address)
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
