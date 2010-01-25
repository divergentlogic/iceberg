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
    # TODO add author attributes
    topic.attributes = {
      :last_post => self,
      :last_updated_at => updated_at,
      :posts_count => topic.posts.count
    }
    topic.save
    board.attributes = {
      :last_post => self,
      :last_topic => topic,
      :last_updated_at => updated_at,
      :posts_count => board.posts.count,
      :topics_count => board.topics.count
    }
    board.save
  end
  
end
