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
  property :last_post_id,     Integer
  attr_accessor :message
  
  belongs_to :forum
  # belongs_to :author, 'Iceberg::User'
  # belongs_to :last_author, 'Iceberg::User'
  has n, :posts
  belongs_to :last_post, 'Iceberg::Post'
  
  validates_present     :message, :on => :create
  validates_present     :forum
  validates_is_unique   :title, :scope => :forum_id, :message => "A topic with that title has been posted in this forum already; maybe you'd like to post under that topic instead?"
  validates_with_method :forum, :method => :validate_forum_allows_topics
  
  before  :valid?,  :set_slug
  after   :create,  :set_post

protected

  def set_slug
    if title && slug.nil?
      attribute_set(:slug, title.to_url)
    end
  end
  
  def set_post
    # TODO set author
    posts.create({
      :forum => forum,
      # :author => author,
      :message => message
    })
  end

  def validate_forum_allows_topics
    if forum && forum.allow_topics?
      true
    else
      [false, "This forum does not allow topics"]
    end
  end
end
