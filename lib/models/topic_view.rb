module Iceberg::Models::TopicView
  include DataMapper::Types

  def self.included(base)
    base.class_eval do

      include DataMapper::Resource

      property :id,                Serial
      property :created_at,        DateTime
      property :viewer_id,         Integer
      property :viewer_name,       String
      property :viewer_ip_address, DataMapper::Types::IPAddress

      belongs_to  :topic

    end
  end
end
