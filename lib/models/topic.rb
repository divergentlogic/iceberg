class Iceberg::Topic
  include DataMapper::Resource
  
  property :id,                     Serial
  property :title,                  String,   :length => (1..250)
  property :slug,                   Slug,     :length => (1..250)
  property :sticky,                 Integer,  :default => 0
  property :locked,                 Boolean
  property :posts_count,            Integer,  :default => 0
  property :view_count,             Integer,  :default => 0
  property :created_at,             DateTime
  property :updated_at,             DateTime
  property :last_updated_at,        DateTime
  property :last_author_id,         Integer
  property :last_author_name,       String
  property :last_author_ip_address, IPAddress

  attr_accessor :author, :message
  
  belongs_to :board
  has n, :posts
  belongs_to :last_post, :model => 'Iceberg::Post', :required => false
  
  validates_present     :message, :on => :create
  validates_present     :board, :title, :slug
  validates_is_unique   :title, :scope => :board_id, :message => "A topic with that title has been posted in this board already; maybe you'd like to post under that topic instead?"
  validates_with_method :board, :method => :validate_board_allows_topics
  
  before  :valid?,  :set_slug
  after   :create,  :set_post
  
  def move_to(board)
    unless self.board == board
      old = self.board
      self.board = board
      if save
        board.update_cache
        old.update_cache
        return true
      end
    end
    return false
  end
  
  def update_cache
    last_post = posts.first(:order => [:updated_at.desc])
    
    self.last_post_id           = last_post ? last_post.id : nil
    self.last_updated_at        = last_post ? last_post.updated_at : nil
    self.last_author_id         = last_post ? last_post.author_id : nil
    self.last_author_name       = last_post ? last_post.author_name : nil
    self.last_author_ip_address = last_post ? last_post.author_ip_address : nil
    self.posts_count            = posts.count
    save! # Don't save up the chain
  end

protected

  def set_slug
    if title && slug.nil?
      attribute_set(:slug, title.to_url)
    end
  end
  
  def set_post
    posts.create({
      :board => board,
      :author => author,
      :message => message
    })
  end

  def validate_board_allows_topics
    if board && board.allow_topics?
      true
    else
      [false, "This board does not allow topics"]
    end
  end
end
