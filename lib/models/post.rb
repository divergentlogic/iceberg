class Iceberg::Post
  include DataMapper::Resource
  
  property :id,         Serial
  property :message,    Text
  property :created_at, DateTime
  property :updated_at, DateTime
  
  belongs_to :topic
  belongs_to :forum
  # belongs_to :author, :model => 'Iceberg::User'
end
