module Iceberg::Models::TopicView
  extend ActiveSupport::Concern

  included do
    include DataMapper::Resource
    include Iceberg::Filters

    property :id,              DataMapper::Property::Serial
    property :created_at,      DataMapper::Property::DateTime
    property :user_id,         DataMapper::Property::Integer, :index => true
    property :user_name,       DataMapper::Property::String
    property :user_ip_address, DataMapper::Property::IPAddress
    property :deleted_at,      DataMapper::Property::ParanoidDateTime

    belongs_to :topic
  end
end
