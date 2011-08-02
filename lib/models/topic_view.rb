module Iceberg::Models::TopicView
  extend ActiveSupport::Concern
  include DataMapper::Types

  included do
    include DataMapper::Resource
    include Iceberg::Filters

    property :id,              Serial
    property :created_at,      DateTime
    property :user_id,         Integer
    property :user_name,       String
    property :user_ip_address, DataMapper::Types::IPAddress
    property :deleted_at,      ParanoidDateTime

    belongs_to :topic
  end
end
