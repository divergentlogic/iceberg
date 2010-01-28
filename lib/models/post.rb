class Iceberg::Post
  include DataMapper::Resource
  
  property :id,         Serial
  property :message,    Text
  property :parent_id,  Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  
  belongs_to :topic
  belongs_to :board
  # belongs_to :author, 'Iceberg::User'
  
  is :tree, :order => :created_at
  
  after :save, :update_caches
  
  def reply(author, attributes)
    returning self.class.new(attributes) do |post| # FIXME should be posts.create ?
      # post.author = author
      post.parent = self
      post.topic = self.topic
      post.board = self.board
    end
  end
  
protected

  def update_caches
    topic.update_cache
    board.update_cache
  end
  
end
