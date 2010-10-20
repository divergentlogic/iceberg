module Iceberg::Models::TopicView
  include DataMapper::Types

  def self.included(base)
    base.class_eval do

      include DataMapper::Resource
      extend Iceberg::Filters

      property :id,              Serial
      property :created_at,      DateTime
      property :user_id,         Integer
      property :user_name,       String
      property :user_ip_address, DataMapper::Types::IPAddress
      property :deleted_at,      ParanoidDateTime

      belongs_to :topic

    end
  end
end
