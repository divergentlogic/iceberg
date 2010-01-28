class Iceberg::Topic
  include DataMapper::Resource
  
  property :id,               Serial
  property :title,            String,   :length => (1..250)
  property :slug,             Slug,     :length => (1..250)
  property :sticky,           Integer,  :default => 0
  property :locked,           Boolean
  property :posts_count,      Integer,  :default => 0
  property :view_count,       Integer,  :default => 0
  property :created_at,       DateTime
  property :updated_at,       DateTime
  property :last_updated_at,  DateTime
  attr_accessor :message
  
  belongs_to :board
  # belongs_to :author, 'Iceberg::User'
  # belongs_to :last_author, 'Iceberg::User'
  has n, :posts
  belongs_to :last_post, :model => 'Iceberg::Post', :required => false
  
  validates_present     :message, :on => :create
  validates_present     :board
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
    # TODO add author attributes
    last_post = posts.first(:order => [:updated_at.desc])
    
    self.last_post_id     = last_post ? last_post.id : nil
    self.last_updated_at  = last_post ? last_post.updated_at : nil
    self.posts_count      = posts.count
    save
  end

protected

  def set_slug
    if title && slug.nil?
      attribute_set(:slug, title.to_url)
    end
  end
  
  def set_post
    # TODO set author
    posts.create({
      :board => board,
      # :author => author,
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
