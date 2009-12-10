class Iceberg::Topic
  include DataMapper::Resource
  
  property :id,               Serial
  property :title,            String,   :length => (1..2000)
  property :slug,             Slug
  property :sticky,           Integer,  :default => 0
  property :locked,           Boolean
  property :posts_count,      Integer,  :default => 0
  property :hits,             Integer,  :default => 0
  property :last_post_id,     Integer
  property :created_at,       DateTime
  property :updated_at,       DateTime
  property :last_updated_at,  DateTime
  attr_accessor :message
  
  belongs_to :forum
  belongs_to :author, :model => 'Iceberg::User'
  belongs_to :last_author, :model => 'Iceberg::User'
  has n, :posts
  
  validates_present   :message, :on => :create
  validates_is_unique :title, :scope => :forum_id, :message => "A topic with that title has been posted in this forum already; maybe you'd like to post under that topic instead?"

  before :valid?, :set_slug
  
  class << self
    def post(author, attributes={})
      topic = new attributes.merge(:author => author)
      topic.last_author = author
      topic.reply author, :message => attributes[:message]
      topic.save
      return topic
    end
  end

  def reply(author, attributes)
    returning posts.new(attributes) do |post| # FIXME should be posts.create ?
      post.author = author
      post.forum = self.forum
      post.topic = self
    end
  end

protected
  def set_slug
    attribute_set(:slug, :title)
  end
end
